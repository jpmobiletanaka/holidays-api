module Extractors
  class SimpleExtractor < BaseExtractor
    def call
      matched = holiday_expr.expression.match(HolidayExpr::SIMPLE_GROUP).to_a.map!(&:to_i)
      month, day = matched[4], matched[6]

      period.map do |year|
        Date.civil(year, month.to_i, day.to_i)
      end
    end
  end
end