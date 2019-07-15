# frozen_string_literal: true
class ProcessFileService < BaseService
  REGION = ENV.fetch('AWS_REGION') { 'ap-northeast-1' }
  BUCKET = ENV.fetch('HOLIDAYS_API_BUCKET') { 'revenue-staging-uploads' }
  PROCESS_SERVICE_NAME = 'Fetchers::S3FetcherService'

  def initialize(file:, user:)
    @file = file
    @user = user
    @s3 = Aws::S3::Resource.new region: REGION
  end

  def call
    save_file!
    queue_for_process
    success
  rescue => e
    error(e)
  end

  private

  attr_reader :file, :s3, :user

  def save_file!
    obj = s3.bucket(BUCKET).object(object_key)
    obj.put(body: file.tempfile)
  end

  def file_name
    @_file_name ||= file.original_filename
  end

  def object_key
    @_object_key ||= "#{Rails.env}/#{file_name}"
  end

  def queue_for_process
    ImportJob.perform_later(PROCESS_SERVICE_NAME, { object_key: object_key })
  end
end
