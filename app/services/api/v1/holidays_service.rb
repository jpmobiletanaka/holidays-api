module Api
  module V1
    class HolidaysService
      def initialize(params)
        @params = params
      end

      def call
        scope.group('holidays.ja_name, holidays.country_code, YEAR(holidays.date)'.arel)
             .where(enabled: true)
             .order('YEAR(holidays.date) ASC, holidays.country_code ASC'.arel)
             .left_joins(:moved_from)
             .pluck(columns_to_select)
             .map! do |ja_name, country_code, en_name, dates, moved_from_dates|
               {
                 country_code: country_code,
                 ja_name: ja_name,
                 en_name: en_name,
                 dates: dates.split(',').sort,
                 moved_from: moved_from_dates&.split(',')&.sort
               }
             end
      end

      private

      attr_reader :params

      def columns_to_select
        %w[
          holidays.ja_name
          holidays.country_code
          ANY_VALUE(holidays.en_name)
          GROUP_CONCAT(holidays.date)
          GROUP_CONCAT(moved_froms_holidays.date)
        ].join(', ').arel
      end

      def scope
        base_year    = params[:year]&.to_i    || Date.current.year
        date_from    = params[:from]&.to_date || Date.civil(base_year, 1, 1)
        date_to      = params[:to]&.to_date   || Date.civil(base_year, 12, 31)
        country_code = params[:country_code]
        @scope     ||= Holiday.by_date(date_from..date_to).by_country_code(country_code)
      end
    end
  end
end