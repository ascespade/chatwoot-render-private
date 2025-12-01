require 'timeout'

class ConfigLoader
  DEFAULT_OPTIONS = {
    config_path: nil,
    reconcile_only_new: true
  }.freeze

  def process(options = {})
    options = DEFAULT_OPTIONS.merge(options)
    # function of the "reconcile_only_new" flag
    # if true,
    #   it leaves the existing config and feature flags as it is and
    #   creates the missing configs and feature flags with their default values
    # if false,
    #   then it overwrites existing config and feature flags with default values
    #   also creates the missing configs and feature flags with their default values
    @reconcile_only_new = options[:reconcile_only_new]

    # setting the config path
    @config_path = options[:config_path].presence
    @config_path ||= Rails.root.join('config')

    # Verify database connection before proceeding
    # If database is unavailable (e.g., during build), skip gracefully
    unless ensure_database_connection
      Rails.logger.debug("[ConfigLoader] Database unavailable, skipping config loading (normal during build)") if defined?(Rails.logger)
      return false
    end

    # general installation configs
    reconcile_general_config

    # default account based feature configs
    reconcile_feature_config
    
    true
  end

  # Public method: Used by GlobalConfig for typecasting
  def general_configs
    @config_path ||= Rails.root.join('config')
    @general_configs ||= YAML.safe_load(File.read("#{@config_path}/installation_config.yml")).freeze
  end

  private

  # Ensure database connection is active
  # Gracefully skips if database is unavailable (e.g., during build phase)
  def ensure_database_connection
    # Try to connect - if it fails, skip gracefully (normal during build when DB doesn't exist)
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      conn.execute('SELECT 1')
    end
    return true
  rescue StandardError => e
    # Any error means database is unavailable - skip gracefully
    # This is normal during Docker build phase when database doesn't exist yet
    Rails.logger.debug("[ConfigLoader] Database unavailable (#{e.class}): #{e.message}. Skipping config load (normal during build).") if defined?(Rails.logger)
    return false
  end

  def account_features
    @account_features ||= YAML.safe_load(File.read("#{@config_path}/features.yml")).freeze
  end

  def reconcile_general_config
    configs = general_configs
    total = configs.length
    processed = 0
    
    configs.each do |config|
      new_config = config.with_indifferent_access
      
      # Use find_by with timeout protection
      existing_config = with_query_timeout do
        InstallationConfig.find_by(name: new_config[:name])
      end
      
      save_general_config(existing_config, new_config)
      processed += 1
      
      # Log progress for large config sets
      if total > 10 && processed % 10 == 0
        puts "[ConfigLoader] Processed #{processed}/#{total} installation configs..."
      end
    end
  end

  def save_general_config(existing, latest)
    if existing
      # save config only if reconcile flag is false and existing configs value does not match default value
      save_as_new_config(latest) if !@reconcile_only_new && compare_values(existing, latest)
    else
      save_as_new_config(latest)
    end
  end

  def compare_values(existing, latest)
    existing.value != latest[:value] ||
      (!latest[:locked].nil? && existing.locked != latest[:locked])
  end

  def save_as_new_config(latest)
    # Use with_query_timeout to prevent hanging on slow database operations
    with_query_timeout do
      config = InstallationConfig.find_or_initialize_by(name: latest[:name])
      config.value = latest[:value]
      config.locked = latest[:locked] unless latest[:locked].nil?
      config.save!
    end
  rescue StandardError => e
    Rails.logger.warn("Failed to save config #{latest[:name]}: #{e.message}") if defined?(Rails.logger)
    # Continue processing other configs even if one fails
  end

  def reconcile_feature_config
    # Use with_query_timeout to prevent hanging
    config = with_query_timeout do
      InstallationConfig.find_by(name: 'ACCOUNT_LEVEL_FEATURE_DEFAULTS')
    end

    if config
      return false if config.value.to_s == account_features.to_s

      compare_and_save_feature(config)
    else
      save_as_new_config({ name: 'ACCOUNT_LEVEL_FEATURE_DEFAULTS', value: account_features, locked: true })
    end
  rescue StandardError => e
    Rails.logger.warn("Failed to reconcile feature config: #{e.message}") if defined?(Rails.logger)
    # Don't fail deployment if feature config reconciliation fails
  end

  def compare_and_save_feature(config)
    features = if @reconcile_only_new
                 # leave the existing feature flag values as it is and add new feature flags with default values
                 (config.value + account_features).uniq { |h| h['name'] }
               else
                 # update the existing feature flag values with default values and add new feature flags with default values
                 (account_features + config.value).uniq { |h| h['name'] }
               end
    
    with_query_timeout do
      config.update({ name: 'ACCOUNT_LEVEL_FEATURE_DEFAULTS', value: features, locked: true })
    end
  rescue StandardError => e
    Rails.logger.warn("Failed to update feature config: #{e.message}") if defined?(Rails.logger)
    # Don't fail deployment if feature update fails
  end

  # Execute database query with timeout protection
  def with_query_timeout(timeout_seconds = 10)
    Timeout.timeout(timeout_seconds) do
      yield
    end
  rescue Timeout::Error => e
    Rails.logger.error("Query timeout in ConfigLoader after #{timeout_seconds}s: #{e.message}") if defined?(Rails.logger)
    raise
  rescue StandardError => e
    Rails.logger.error("Query error in ConfigLoader: #{e.message}") if defined?(Rails.logger)
    raise
  end
end
