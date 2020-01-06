module Api
  module V1
    class HolidaysService
      HOLIDAY_ATTRS = %w[id country_code ja_name en_name observed day_off current_source_type].freeze

      def initialize(params)
        @params = params
      end

      def call
        scope.group_by(&holiday_rel).map do |holiday, days|
          holiday.slice(*select_attrs).merge(
            dates: days.select(&:enabled?).map!(&:date).sort,
            moves: moves(days),
            destroyed: holiday.respond_to?(:holiday) && holiday.holiday.nil?
          )
        end
      end

      private

      def select_attrs
        return HOLIDAY_ATTRS unless history_request?
        ['holiday_id', *HOLIDAY_ATTRS]
      end

      def holiday_rel
        @_holiday_rel ||= history_request? ? :holiday_history : :holiday
      end

      def history_request?
        @_history_request ||= params[:state_at].present?
      end

      attr_reader :params

      def moves(days)
        days.map! do |day|
          next if day.enabled?
          { from: day.date, to: day.moved_to_date }
        end.compact!
      end

      def base_year
        @_base_year ||= params[:year]&.to_i || Date.current.year
      end

      def date_from
        @_date_from ||= params[:from]&.to_date || Date.civil(base_year, 1, 1)
      end

      def date_to
        @_date_to ||= params[:to]&.to_date || Date.civil(base_year, 12, 31)
      end

      def scope
        where_option = {}
        where_option = { holidays: { country_code: params[:country_code] } } if params[:country_code]
        return history_holidays if history_request?
        @scope ||= Day.by_date(date_from..date_to).includes(:holiday, :moved_to).where(where_option)
      end

      def history_holidays
        date = params[:state_at].to_date
        subquery = HolidayHistory
                   .select(:holiday_id,
                           'row_number() OVER (PARTITION BY holiday_id ORDER BY date DESC) AS ts_position')
                   .where("date <= ?::date", date)
        subquery = subquery.where(country_code: params[:country_code]) if params[:country_code].present?

        @scope ||= Day.by_date(date_from..date_to)
                      .joins("INNER JOIN (#{subquery.to_sql}) t USING(holiday_id)")
                      .includes(:moved_to, holiday_history: :holiday)
                      .where("t.ts_position <= ?", 1)
      end
    end
  end
end
