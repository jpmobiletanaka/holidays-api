module Api
  module V1
    class HolidaysService
      def initialize(params)
        @params = params
      end

      def call
        scope.group_by(&:holiday).map do |holiday, days|
          {
            id: holiday.id,
            country_code: holiday.country_code,
            ja_name: holiday.ja_name,
            en_name: holiday.en_name,
            dates: days.select(&:enabled?).map!(&:date).sort,
            moves: moves(days)
          }
        end
      end

      private

      attr_reader :params

      def moves(days)
        days.map! do |day|
          next if day.enabled?
          { from: day.date, to: day.moved_to_date }
        end.compact!
      end

      def scope
        base_year    = params[:year]&.to_i    || Date.current.year
        date_from    = params[:from]&.to_date || Date.civil(base_year, 1, 1)
        date_to      = params[:to]&.to_date   || Date.civil(base_year, 12, 31)
        where_option = {}
        where_option = { holidays: { country_code: params[:country_code] } } if params[:country_code]
        return history_holidays if params[:date].present?
        @scope     ||= Day.by_date(date_from..date_to).includes(:holiday, :moved_to).where(where_option)
      end

      def history_holidays
        date = params[:date]&.to_date
        @scope ||= Day.includes(:holiday)
                      .references(:holiday)
                      .joins('INNER JOIN holiday_expr_histories ON holiday_expr_histories.holiday_expr_id = holidays.holiday_expr_id')
                      .where(holiday_expr_histories: { date: date.prev_year..date })
      end
    end
  end
end
