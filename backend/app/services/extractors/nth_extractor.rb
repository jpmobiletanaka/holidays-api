module Extractors
  class NthExtractor < BaseExtractor
    def call
      matched = holiday_expr.expression.match(HolidayExpr::NTH_DAY_GROUP).to_a.map!(&:to_i)
      @month, @nth, @day_of_week, @add = matched[4], matched[7], matched[9], matched[12]

      @sign = nth <=> 0
      @nth  = sign * (nth.abs - 1)
      period.map do |year|
        extract_date(year)
      end
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    def extract_date(year)
      week_num = nth.dup
      first_week_of_year      = Date.commercial(year, 1, 1)   # 1
      last_week_of_year       = Date.commercial(year, -1, -1) # 54

      bom = Date.civil(year, month, 1)
      bom = first_week_of_year if bom.cweek >= last_week_of_year.cweek

      eom = bom.end_of_month
      eom = last_week_of_year if eom.cweek <= first_week_of_year.cweek

      week_num += bom.cweek + (bom.cwday > day_of_week ? 1 : 0) if sign.positive?
      week_num += eom.cweek - (eom.cwday < day_of_week ? 1 : 0) if sign.negative?

      date = Date.commercial(year, week_num, day_of_week) + add.to_i.days
      return unless date.month == month.to_i

      date
    end
    # rubocop:enable Metrics/CyclomaticComplexity

    private

    attr_reader :month, :nth, :day_of_week, :add, :sign, :nth_orig

    # def old
    #   sign     = nth <=> 0
    #   nth_orig = sign * (nth.abs - 1)
    #   period.map do |year|
    #     nth = nth_orig
    #     last_week = Date.commercial(year, -1, -1)
    #     bom = month == 1 ? Date.commercial(year, 1, 1) : Date.civil(year, month.to_i, 1)
    #     eom = bom.end_of_month.cweek < bom.cweek ? last_week : bom.end_of_month
    #     week_number = if sign.positive?
    #                     nth += 1 if bom.cwday > day_of_week
    #                     bom.cweek + nth
    #                   else
    #                     nth -= 1 if eom.cwday < day_of_week
    #                     eom.cweek + nth
    #                   end
    #     if week_number > last_week.cweek
    #       week_number -= last_week.cweek
    #       year += 1
    #     end
    #     date = Date.commercial(year, week_number, day_of_week) + add.to_i.days
    #     return [] unless date.month == month.to_i
    #     date
    #   end
    # end
  end
end