class FileRawHoliday < ApplicationRecord
  include Concerns::HolidaySource

  validates :en_name, :ja_name, presence: true

  scope :pending, -> { where(state: :pending) }
end
