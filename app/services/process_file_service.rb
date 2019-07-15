class SaveFileService < BaseService
  def initialize(file, user)
    @file = file
    @user = user
  end

  def call
    return success if save_file
    error
  end

  private

  attr_reader :file, :s3, :user

  def save_file
  end
end
