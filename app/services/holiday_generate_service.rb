class HolidayGenerateService
  attr_reader :period, :holiday_expr

  def initialize(holiday_expr, start_date: 1970, end_date: 2038)
    @holiday_expr = holiday_expr
    if holiday_expr.with_year?
      year = holiday_expr.expression.match(HolidayExpr::YEAR).to_a.first.to_i
      start_date, end_date = year, year
    end
    @period = start_date..end_date
  end

  def call
    days_attrs = extract_dates.map! { |date| extract_day_attributes(date) }.compact
    Day.import!(days_attrs, on_duplicate_key_ignore: true, validate: false)
    holiday_expr.processed!
  end

  private

  def holiday
    @holiday ||= holiday_expr.holidays.find_or_create_by(holiday_attributes)
  end

  def extract_day_attributes(date)
    { date: date.send(holiday_expr.calendar_type), holiday_id: holiday.id }
  rescue ArgumentError
    nil
  end

  def holiday_attributes
    {
      holiday_expr_id: holiday_expr.id,
      country_code: holiday_expr.country_code,
      ja_name: holiday_expr.ja_name,
      en_name: holiday_expr.en_name,
      source: :manual,
      enabled: true
    }
  end

  def extract_dates
    generator = case holiday_expr.expression
                when HolidayExpr::MOON_GROUP
                  Extractors::MoonExtractor
                when HolidayExpr::NTH_DAY_GROUP
                  Extractors::NthExtractor
                when HolidayExpr::PERIOD_GROUP
                  Extractors::PeriodExtractor
                when HolidayExpr::LARGE_PERIOD_GROUP
                  Extractors::LargePeriodExtractor
                when HolidayExpr::SIMPLE_GROUP
                  Extractors::SimpleExtractor
                end
    generator.new(holiday_expr, period).call
  end
end