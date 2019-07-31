require 'carrierwave/orm/activerecord'

CarrierWave.configure do |config|
  config.storage = :file

  if Rails.env.test? || Rails.env.cucumber?
    config.enable_processing = false
  end

  if ENV['HOLIDAYS_API_BUCKET']
    config.fog_provider = 'fog/aws'

    config.fog_public = false
    pp ENV
    config.fog_credentials = {
      provider:              'AWS',
      aws_access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      region:                ENV['AWS_REGION']
    }

    config.fog_directory = ENV['HOLIDAYS_API_BUCKET']
  end
end

TEMP_LOCAL_COPIES_FOLDER = Rails.root.join('local_storage', 'temp')

FileUtils.mkdir_p(TEMP_LOCAL_COPIES_FOLDER) unless File.exist?(TEMP_LOCAL_COPIES_FOLDER)
