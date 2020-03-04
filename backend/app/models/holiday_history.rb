class HolidayHistory < ApplicationRecord
  belongs_to :holiday

  enum current_source_type: %i[manual file google]

  delegate :recurring, :recurring?, to: :holiday, allow_nil: true
end
