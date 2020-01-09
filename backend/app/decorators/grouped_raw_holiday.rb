class GroupedRawHoliday
  attr_reader :holiday

  def initialize(holiday)
    @holiday = holiday
  end

  delegate_missing_to :holiday

  def ja_names
    JSON.parse(ja_name) rescue {}
  end

  def extracted_dates
    holiday.min_date..holiday.max_date
  end

  def calendar_type
    :gregorian
  end
end
