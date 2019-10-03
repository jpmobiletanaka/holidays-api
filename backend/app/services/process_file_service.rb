# frozen_string_literal: true

class ProcessFileService < BaseService
  REGION = ENV.fetch('AWS_REGION') { 'ap-northeast-1' }
  BUCKET = ENV.fetch('HOLIDAYS_API_BUCKET') { 'revenue-staging-uploads' }
  PROCESS_SERVICE_NAME = 'Fetchers::S3FetcherService'

  def initialize(file:, user:)
    @file = file
    @user = user
  end

  def call
    save_file!
    queue_for_process
    success
  rescue StandardError => e
    error(e)
  end

  private

  attr_reader :file, :user, :upload

  def save_file!
    @upload = user.uploads.new(status: Upload.statuses[:pending])
    @upload.file = file
    @upload.save!
  end

  def file_name
    @_file_name ||= file.original_filename
  end

  def queue_for_process
    ImportJob.perform_later(PROCESS_SERVICE_NAME, upload_id: upload.id)
  end
end
