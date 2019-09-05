module Extractors
  class PeriodExtractor < BaseExtractor
    def call
      matched = holiday_expr.expression.match(HolidayExpr::PERIOD_GROUP).to_a.map!(&:to_i)
      start_month, end_month = matched[4], matched[4]
      start_day, end_day = matched[6..7]

      [].tap do |dates|
        period.each do |year|
          from  = Date.civil(year, start_month.to_i, start_day.to_i)
          year += 1 if start_month > end_month
          to    = Date.civil(year, end_month.to_i, end_day.to_i)
          dates.concat((from..to).to_a)
        end
      end
    end
  end
end