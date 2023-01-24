class HolidayHistory < ApplicationRecord
  belongs_to :holiday

  enum current_source_type: { manual: 0, file: 1, google: 2 }

  delegate :recurring, :recurring?, to: :holiday, allow_nil: true
end
