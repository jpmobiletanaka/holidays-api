class Holiday < ApplicationRecord
  enum source: %i[manual google]

  belongs_to :holiday_expr, optional: true
  belongs_to :country, primary_key: :country_code, foreign_key: :country_code

  has_many :days
end
