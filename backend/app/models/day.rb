class Day < ApplicationRecord
  belongs_to :holiday, optional: true
  belongs_to :moved_from, class_name: 'Day', foreign_key: :moved_from_id, optional: true

  has_one :country, through: :holiday
  has_one :holiday_expr, through: :holiday
  has_one :moved_to, class_name: 'Day', foreign_key: :moved_from_id

  scope :by_date, ->(date) { where(date: date) }

  delegate :date, to: :moved_to, prefix: true, allow_nil: true

  def move_to(date)
    return if date.to_date == self.date
    new_day = Day.create(holiday_id: holiday_id, date: date, moved_from_id: id)
    update(enabled: false)
    new_day
  end
end
