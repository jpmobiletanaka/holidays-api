module Extractors
  class LargePeriodExtractor < BaseExtractor
    def call
      matched = holiday_expr.expression.match(HolidayExpr::LARGE_PERIOD_GROUP).to_a.map!(&:to_i)
      start_month, start_day, end_month, end_day = matched[5], matched[7], matched[9], matched[11]

      period.map do |year|
        from  = Date.civil(year, start_month.to_i, start_day.to_i)
        year += 1 if start_month > end_month
        to    = Date.civil(year, end_month.to_i, end_day.to_i)
        (from..to).to_a
      end.flatten
    end
  end
end