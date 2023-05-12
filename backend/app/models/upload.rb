class Upload < ApplicationRecord
  PROCESS_SERVICE_NAME = 'Fetchers::FetchFromUploadService'.freeze

  mount_uploader :file, HolidaysUploader

  enum status: { pending: 0, in_progress: 1, success: 2, error: 3 }

  validates :file, presence: true

  belongs_to :user

  def process_file!
    ImportJob.perform_later(PROCESS_SERVICE_NAME, object_key: object_key)
  end

  def file_info
    { name: file.file_name, url: file.url }
  end
end
