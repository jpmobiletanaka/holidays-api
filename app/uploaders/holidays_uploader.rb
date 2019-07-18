class HolidaysUploader < CarrierWave::Uploader::Base

  def self.set_storage
    if ENV['HOLIDAYS_API_BUCKET'] && (Rails.env.production? || Rails.env.staging? || Rails.env.development?)
      :fog
    else
      :file
    end
  end

  storage set_storage

  def file_name
    file&.filename
  end

  def file_exists?
    file.present? && (local_storage? ? File.exist?(file.path) : file.exists?)
  end

  def local_storage?
    _storage.to_s == 'CarrierWave::Storage::File'
  end

  def temp_local_copy
    return unless file_exists?
    return if local_storage?

    temp_file_name = "#{SecureRandom.uuid}.#{file.extension}"
    temp_file_path = File.join(TEMP_LOCAL_COPIES_FOLDER, temp_file_name)

    # IO.copy_stream(open(url), temp_file_path)

    # # TODO: maybe needs some checks
    File.open(temp_file_path, 'wb') do |file|
      HTTParty.get(url, stream_body: true) do |fragment|
        file.write(fragment)
      end
    end

    CarrierWave::SanitizedFile.new(temp_file_path)
  end

  def extension_whitelist
    %w[csv dat]
  end

  private

  def directory_suffixes
    [Rails.env, model.model_name.param_key, model.id.to_s]
  end

  def timestamp
    var = :"@#{mounted_as}_timestamp"
    model.instance_variable_get(var) || model.instance_variable_set(var, Time.current.strftime("%Y_%m_%d-%H_%M_%S_%9N"))
  end
end
