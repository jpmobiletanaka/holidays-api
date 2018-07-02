class HolidayGenerateService
  attr_reader :period_to_generate, :holiday_expr

  def initialize(holiday_expr, start_date: 1970, end_date: 2038)
    @holiday_expr = holiday_expr
    if holiday_expr.with_year?
      year = holiday_expr.expression.match(HolidayExpr::YEAR).to_a.first.to_i
      start_date, end_date = year, year
    end
    @period_to_generate = start_date..end_date
  end

  def call
    holiday_attrs = extract_dates.map! { |date| extract_attributes(date) }
    Holiday.import!(holiday_attrs, on_duplicate_key_update: %i[ja_name en_name date country_code], validate: false)
    holiday_expr.processed!
  end

  private

  def extract_attributes(date)
    {
      date: date.send(holiday_expr.calendar_type),
      holiday_expr_id: holiday_expr.id,
      country_code: holiday_expr.country_code,
      ja_name: holiday_expr.ja_name,
      en_name: holiday_expr.en_name,
      source: :manual
    }
  end

  # rubocop:disable Metrics/MethodLength
  def extract_dates
    case holiday_expr.expression
    when HolidayExpr::MOON_GROUP
      matched = holiday_expr.expression.match(HolidayExpr::MOON_GROUP).to_a.map!(&:to_i)
      month, add = matched[4], matched[9]
      full_moon(month, add)
    when HolidayExpr::NTH_DAY_GROUP
      matched = holiday_expr.expression.match(HolidayExpr::NTH_DAY_GROUP).to_a.map!(&:to_i)
      month, nth, day_of_week, add = matched[4], matched[7], matched[9], matched[12]
      nth_day(month, nth, day_of_week, add)
    when HolidayExpr::PERIOD_GROUP
      matched = holiday_expr.expression.match(HolidayExpr::PERIOD_GROUP).to_a.map!(&:to_i)
      start_month, end_month = matched[4], matched[4]
      start_day, end_day = matched[6..7]
      period(start_month, start_day, end_month, end_day)
    when HolidayExpr::LARGE_PERIOD_GROUP
      matched = holiday_expr.expression.match(HolidayExpr::LARGE_PERIOD_GROUP).to_a.map!(&:to_i)
      start_month, start_day, end_month, end_day = matched[5], matched[7], matched[9], matched[11]
      period(start_month, start_day, end_month, end_day)
    when HolidayExpr::SIMPLE_GROUP
      matched = holiday_expr.expression.match(HolidayExpr::SIMPLE_GROUP).to_a.map!(&:to_i)
      month, day = matched[4], matched[6]
      simple(month, day)
    end
  end
  # rubocop:enable Metrics/MethodLength

  def simple(month, day)
    period_to_generate.map do |year|
      Date.civil(year, month.to_i, day.to_i)
    end
  end

  def nth_day(month, nth, day_of_week, add)
    sign     = nth <=> 0
    nth_orig = sign * (nth.abs - 1)
    period_to_generate.map do |year|
      nth = nth_orig
      last_week = Date.commercial(year, -1, -1)
      bom = Date.civil(year, month.to_i, 1)                                   # beginning of month
      eom = bom.end_of_month.cweek < bom.cweek ? last_week : bom.end_of_month # end of month
      week_number = if sign.positive?
                      nth += 1 if bom.cwday > day_of_week
                      bom.cweek + nth
                    else
                      nth -= 1 if eom.cwday < day_of_week
                      eom.cweek + nth
                    end
      if week_number > last_week.cweek
        week_number -= last_week.cweek
        year += 1
      end
      Date.commercial(year, week_number, day_of_week) + add.to_i.days
    end
  end

  def period(start_month, start_day, end_month, end_day)
    [].tap do |dates|
      period_to_generate.each do |year|
        from  = Date.civil(year, start_month.to_i, start_day.to_i)
        year += 1 if start_month > end_month
        to    = Date.civil(year, end_month.to_i, end_day.to_i)
        dates.concat((from..to).to_a)
      end
    end
  end

  def full_moon(month, add)
    period_to_generate.map do |year|
      days = FullMoonService.in(year, month)
      days.map! { |day| Date.civil(year, month.to_i, day.to_i) + add.to_i.days }
    end.flatten
  end

  def delimiter
    @delimiter ||= holiday_expr.expression.include?('/') ? '/' : '.'
  end
end