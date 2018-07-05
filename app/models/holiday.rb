class Holiday < ApplicationRecord
  enum source: %i[manual google]

  belongs_to :holiday_expr, optional: true
  belongs_to :country, primary_key: :country_code, foreign_key: :country_code

  has_many :days

  scope :enabled,         -> { where(enabled: true) }
  scope :by_name,         ->(name) { where(en_name: name).or(where(ja_name: name)) }
  scope :by_country_code, ->(country_code) { where(country_code: country_code) if country_code.present? }
end
