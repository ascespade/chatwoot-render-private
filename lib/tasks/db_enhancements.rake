require 'timeout'

# We are hooking config loader to run automatically everytime migration is executed
Rake::Task['db:migrate'].enhance do
  # Check if table exists with timeout protection
  table_exists = begin
    Timeout.timeout(5) do
      ActiveRecord::Base.connection.table_exists?('installation_configs')
    end
  rescue StandardError => e
    puts "WARNING: Could not check installation_configs table: #{e.message}"
    false
  end

  if table_exists
    puts 'Loading Installation config'
    start_time = Time.current
    
    begin
      # Reduced timeout to 30 seconds for faster failure
      # Config loading should be fast, if it takes longer, something is wrong
      Timeout.timeout(30) do
        ConfigLoader.new.process
        elapsed = (Time.current - start_time).round(2)
        puts "Installation config loaded successfully in #{elapsed}s"
      end
    rescue Timeout::Error => e
      elapsed = (Time.current - start_time).round(2)
      puts "WARNING: ConfigLoader timed out after #{elapsed} seconds: #{e.message}"
      puts "Continuing deployment - configs can be loaded later via rake task"
      Rails.logger.warn("ConfigLoader timeout after #{elapsed}s: #{e.message}") if defined?(Rails.logger)
    rescue ActiveRecord::StatementInvalid => e
      puts "WARNING: ConfigLoader database error: #{e.message}"
      puts "Continuing deployment - configs can be loaded later"
      Rails.logger.error("ConfigLoader database error: #{e.class}: #{e.message}") if defined?(Rails.logger)
    rescue StandardError => e
      elapsed = (Time.current - start_time).round(2)
      puts "WARNING: ConfigLoader failed after #{elapsed}s: #{e.class}: #{e.message}"
      puts "Continuing deployment - configs can be loaded later via: bundle exec rake db:load_config"
      Rails.logger.error("ConfigLoader error: #{e.class}: #{e.message}\n#{e.backtrace.first(5).join("\n")}") if defined?(Rails.logger)
    end
  else
    puts "Skipping Installation config loading (table not found or database unavailable)"
  end
end

# we are creating a custom database prepare task
# the default rake db:prepare task isn't ideal for environments like heroku
# In heroku the database is already created before the first run of db:prepare
# In this case rake db:prepare tries to run db:migrate from all the way back from the beginning
# Since the assumption is migrations are only run after schema load from a point x, this could lead to things breaking.
# ref: https://github.com/rails/rails/blob/main/activerecord/lib/active_record/railties/databases.rake#L356
db_namespace = namespace :db do
  desc 'Runs setup if database does not exist, or runs migrations if it does'
  task chatwoot_prepare: :load_config do
    begin
      ActiveRecord::Base.configurations.configs_for(env_name: Rails.env).each do |db_config|
        ActiveRecord::Base.establish_connection(db_config.configuration_hash)
        unless ActiveRecord::Base.connection.table_exists? 'ar_internal_metadata'
          db_namespace['load_config'].invoke if ActiveRecord::Base.schema_format == :ruby
          ActiveRecord::Tasks::DatabaseTasks.load_schema_current(:ruby, ENV.fetch('SCHEMA', nil))
          db_namespace['seed'].invoke
        end

        db_namespace['migrate'].invoke
      rescue ActiveRecord::NoDatabaseError => e
        begin
          db_namespace['setup'].invoke
        rescue StandardError => setup_error
          # If setup fails due to database unavailability, skip gracefully
          raise setup_error
        end
      end
    rescue ActiveRecord::NoDatabaseError, PG::ConnectionBad, PG::UndefinedDatabase, StandardError => e
      # Database unavailable during build (normal during Docker build phase)
      # Skip gracefully - migrations will run on application startup when DB is available
      error_message = e.message.to_s.downcase
      if error_message.include?('database') || error_message.include?('connection') || 
         error_message.include?('could not find') || error_message.include?('could not translate') ||
         error_message.include?('could not create') || error_message.include?('name or service not known')
        puts "⚠ Skipped database preparation (database unavailable - normal during build)"
        puts "Database will be prepared automatically on application startup when database is available."
        # Don't fail the build - this is expected during Docker build phase
      else
        # Re-raise unexpected errors
        raise
      end
    end
  end
end

# Manual task to load installation configs (useful if auto-loading fails during deployment)
namespace :db do
  desc 'Load installation configuration (can be run manually if deployment hangs)'
  task load_config: :environment do
    puts 'Loading Installation config manually...'
    start_time = Time.current
    
    begin
      Timeout.timeout(30) do
        result = ConfigLoader.new.process
        elapsed = (Time.current - start_time).round(2)
        if result
          puts "✓ Installation config loaded successfully in #{elapsed}s"
        else
          puts "⚠ Skipped Installation config loading (database unavailable - normal during build)"
        end
      end
    rescue Timeout::Error => e
      elapsed = (Time.current - start_time).round(2)
      puts "✗ ERROR: ConfigLoader timed out after #{elapsed} seconds"
      puts "This usually indicates a database connection issue."
      puts "Please check:"
      puts "  - Database is accessible"
      puts "  - Database connection string is correct"
      puts "  - Network connectivity to database"
      exit 1
    rescue StandardError => e
      elapsed = (Time.current - start_time).round(2)
      puts "✗ ERROR: ConfigLoader failed after #{elapsed}s: #{e.class}: #{e.message}"
      puts e.backtrace.first(5).join("\n")
      exit 1
    end
  end
end
