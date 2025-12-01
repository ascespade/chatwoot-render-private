require 'rubygems/package'
require 'timeout'

namespace :ip_lookup do
  task setup: :environment do
    puts '[rake ip_lookup:setup] Starting IP lookup setup...'
    
    # Check if database file already exists
    if File.exist?(GeocoderConfiguration::LOOK_UP_DB)
      puts '[rake ip_lookup:setup] GeoIP database already exists. Skipping setup.'
      next
    end

    ip_lookup_api_key = ENV.fetch('IP_LOOKUP_API_KEY', nil)
    if ip_lookup_api_key.blank?
      puts '[rake ip_lookup:setup] IP_LOOKUP_API_KEY empty. Skipping geoip database setup'
      Rails.logger.info '[rake ip_lookup:setup] IP_LOOKUP_API_KEY empty. Skipping geoip database setup' if defined?(Rails.logger)
      next
    end

    puts '[rake ip_lookup:setup] Fetch GeoLite2-City database'
    Rails.logger.info '[rake ip_lookup:setup] Fetch GeoLite2-City database' if defined?(Rails.logger)

    begin
      # Add timeout to prevent hanging
      Timeout.timeout(60) do
        base_url = ENV.fetch('IP_LOOKUP_BASE_URL', 'https://download.maxmind.com/app/geoip_download')
        source_file = Down.download(
          "#{base_url}?edition_id=GeoLite2-City&suffix=tar.gz&license_key=#{ip_lookup_api_key}"
        )

        tar_extract = Gem::Package::TarReader.new(Zlib::GzipReader.open(source_file))
        tar_extract.rewind

        tar_extract.each do |entry|
          next unless entry.full_name.include?('GeoLite2-City.mmdb') && entry.file?

          FileUtils.mkdir_p(File.dirname(GeocoderConfiguration::LOOK_UP_DB))
          File.open GeocoderConfiguration::LOOK_UP_DB, 'wb' do |f|
            f.print entry.read
          end
        end
        puts '[rake ip_lookup:setup] Fetch complete'
        Rails.logger.info '[rake ip_lookup:setup] Fetch complete' if defined?(Rails.logger)
      end
    rescue Timeout::Error
      error_msg = '[rake ip_lookup:setup] Timeout: Failed to download GeoIP database within 60 seconds. Continuing without it.'
      puts error_msg
      Rails.logger.error error_msg if defined?(Rails.logger)
      # Continue without the database - app should still work
    rescue StandardError => e
      error_msg = "[rake ip_lookup:setup] Error: #{e.message}"
      puts error_msg
      Rails.logger.error error_msg if defined?(Rails.logger)
      # Continue without the database - app should still work
    end
    
    puts '[rake ip_lookup:setup] Finished'
  end
end
