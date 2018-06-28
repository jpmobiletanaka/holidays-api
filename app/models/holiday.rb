class Holiday < ApplicationRecord
  enum source: %i[manual google]

  belongs_to :moved_from, class_name: 'Holiday', optional: true
  belongs_to :holiday_expr, optional: true
  belongs_to :country, primary_key: :country_code, foreign_key: :country_code

  has_one :moved_to, class_name: 'Holiday', foreign_key: 'moved_from_id'

  scope :by_date,         ->(date) { where(date: date) }
  scope :by_year,         ->(year) { where(date: Date.civil(year.to_i, 1, 1).all_year) }
  scope :by_country_code, ->(country_code) { where(country_code: country_code) if country_code.present? }

  def move_to(date_to_move)
    needed_attributes = attributes.slice('country_code', 'ja_name', 'en_name', 'source')
    needed_attributes['moved_from'] = self
    needed_attributes['date']       = date_to_move
    moved_to = self.class.create!(needed_attributes)
    update(enabled: false)
    moved_to
  end

  def moved?
    moved_to.present? || moved_from.present?
  end
end
