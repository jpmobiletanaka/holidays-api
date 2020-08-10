module Extractors
  class XLargePeriodExtractor < BaseExtractor
    def call
      matched = holiday_expr.expression.match(HolidayExpr::XLARGE_PERIOD_GROUP).to_a.map!(&:to_i)
      start_year, start_month, start_day, end_year, end_month, end_day =
        matched[2], matched[4], matched[6], matched[8], matched[10], matched[12]

      from = Date.civil(start_year.to_i, start_month.to_i, start_day.to_i)
      to = Date.civil(end_year, end_month.to_i, end_day.to_i)
      (from..to).to_a
    end
  end
end