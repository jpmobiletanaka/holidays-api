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
      aws_access_key_id:     ENV.fetch('AWS_ACCESS_KEY_ID', 'ap-northeast-1'),
      aws_secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY', 'ap-northeast-1'),
      region:                ENV.fetch('AWS_REGION', 'ap-northeast-1')
    }

    config.fog_directory = ENV.fetch('HOLIDAYS_API_BUCKET')
  end
end

TEMP_LOCAL_COPIES_FOLDER = Rails.root.join('local_storage', 'temp')

FileUtils.mkdir_p(TEMP_LOCAL_COPIES_FOLDER) unless File.exist?(TEMP_LOCAL_COPIES_FOLDER)
