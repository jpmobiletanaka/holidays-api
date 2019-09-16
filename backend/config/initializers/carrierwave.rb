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
      aws_access_key_id:     Rails.application.credentials.aws[:access_key_id],
      aws_secret_access_key: Rails.application.credentials.aws[:secret_access_key],
      region:                Rails.application.credentials.aws[:region]
    }

    config.fog_directory = ENV['HOLIDAYS_API_BUCKET']
  end
end

TEMP_LOCAL_COPIES_FOLDER = Rails.root.join('local_storage', 'temp')

FileUtils.mkdir_p(TEMP_LOCAL_COPIES_FOLDER) unless File.exist?(TEMP_LOCAL_COPIES_FOLDER)
