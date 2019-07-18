class Upload < ApplicationRecord
  PROCESS_SERVICE_NAME = 'Fetchers::S3FetcherService'

  mount_uploader :file, HolidaysUploader

  enum status: %i[pending in_progress success error]

  validates :file, presence: true

  belongs_to :user

  def process_file!
    ImportJob.perform_later(PROCESS_SERVICE_NAME, { object_key: object_key })
  end

  def file_info
    { name: file.file_name, url: file.url }
  end
end
