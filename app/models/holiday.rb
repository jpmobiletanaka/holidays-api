class Holiday < ApplicationRecord
  enum source: %i[manual google]

  belongs_to :holiday_expr, optional: true
  belongs_to :country, primary_key: :country_code, foreign_key: :country_code

  scope :by_date,         ->(date) { where(date: date) }
  scope :by_year,         ->(year) { where(date: Date.civil(year.to_i, 1, 1).all_year) }
  scope :by_country_code, ->(country_code) { where(country_code: country_code) if country_code.present? }
end
