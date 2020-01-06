class GroupedRawHoliday
  attr_reader :holiday

  def initialize(holiday)
    @holiday = holiday
  end

  delegate_missing_to :holiday

  def ja_names
    JSON.parse(ja_name) rescue {}
  end
end
