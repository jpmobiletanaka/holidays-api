class Holiday < ApplicationRecord
  enum current_source_type: { manual: 0, file: 1, google: 2 }

  belongs_to :holiday_expr, optional: true
  belongs_to :country, primary_key: :country_code, foreign_key: :country_code

  has_many :days
  has_many :google_raw_holidays
  has_many :file_raw_holidays
  has_many :history_records, class_name: 'HolidayHistory'

  alias manual_raw_holidays holiday_expr

  def sources
    source_ids.keys.each_with_object([]) do |source, res|
      res.push(*send("#{source}_raw_holidays"))
    end
  end

  # TODO: Denormalize to separate field
  delegate :recurring?, to: :holiday_expr, allow_nil: true

  def dates
    days.enabled.pluck(:date).sort
  end
end
