class Country < ApplicationRecord
  AVAILABLE_COUNTRIES = %w[cn jp kr tw th hk my us].freeze

  has_many :holidays, primary_key: :country_code, foreign_key: :country_code

  scope :available, -> { where(country_code: AVAILABLE_COUNTRIES) }
end
