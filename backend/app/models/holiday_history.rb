class HolidayHistory < ApplicationRecord
  belongs_to :holiday

  enum current_source_type: %i[manual file google]
end
