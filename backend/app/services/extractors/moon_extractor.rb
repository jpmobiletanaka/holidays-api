module Extractors
  class MoonExtractor < BaseExtractor
    def call
      matched = holiday_expr.expression.match(HolidayExpr::MOON_GROUP).to_a.map!(&:to_i)
      month, add = matched[4], matched[9]

      period.map do |year|
        days = FullMoonService.in(year, month)
        days.map! { |day| Date.civil(year, month.to_i, day.to_i) + add.to_i.days }
      end.flatten
    end
  end
end