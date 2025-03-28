class ManualRawHoliday
  attr_reader :holiday_expr, :period

  def initialize(holiday_expr, period)
    @holiday_expr = holiday_expr
    @period = period
  end

  delegate_missing_to :holiday_expr

  def extracted_dates
    @_extracted_dates ||= generator.new(holiday_expr, period).call
  end

  def ids
    { id => extracted_dates }
  end

  def ja_names
    [ja_name]
  end

  def min_date
    extracted_dates.min
  end

  def max_date
    extracted_dates.max
  end

  private

  # rubocop:disable Metrics/CyclomaticComplexity
  def generator
    @_generator ||=
      case holiday_expr.expression
      when HolidayExpr::MOON_GROUP
        Extractors::MoonExtractor
      when HolidayExpr::NTH_DAY_GROUP
        Extractors::NthExtractor
      when HolidayExpr::PERIOD_GROUP
        Extractors::PeriodExtractor
      when HolidayExpr::LARGE_PERIOD_GROUP
        Extractors::LargePeriodExtractor
      when HolidayExpr::XLARGE_PERIOD_GROUP
        Extractors::XLargePeriodExtractor
      when HolidayExpr::SIMPLE_GROUP
        Extractors::SimpleExtractor
      end
  end
  # rubocop:enable Metrics/CyclomaticComplexity
end
