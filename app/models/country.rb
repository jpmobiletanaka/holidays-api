class Country < ApplicationRecord
  has_many :holidays, primary_key: :country_code, foreign_key: :country_code
end
