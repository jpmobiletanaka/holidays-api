module Generators
  module Manual
    class GenerateHolidays
      include Generators::Concerns::FindBySimilarity
      include Generators::Concerns::ValidateHolidays
      include Generators::Concerns::ProcessHolidays
      include Generators::Concerns::PersistHolidays

      SIMILARITY_THRESHOLD = 0.6
      SOURCE = :manual
      COUNTRY_FIELD = :country_code
      HOLIDAY_FIELDS = %w[en_name ja_name observed day_off country_code].freeze
      RAW_HOLIDAY_FIELDS = %w[ja_name en_name country_code expression].freeze

      attr_reader :holiday_expr

      def initialize(holiday_expr, start_date: 1970, end_date: 2038)
        if holiday_expr.with_year?
          year = holiday_expr.expression.match(HolidayExpr::YEAR).to_a.first.to_i
          start_date, end_date = year, year
        end
        @holiday_expr = ManualRawHoliday.new(holiday_expr, start_date..end_date)
      end

      def call
        holidays = find_holidays_matching_date_range(holiday_expr)
        process_holidays(holidays.to_a, holiday_expr)

        ActiveRecord::Base.transaction do
          destroy_old_holidays
          save_holidays
          save_days
          holiday_expr.processed!
        end
      end

      private

      def raw_holiday_class
        HolidayExpr
      end

      def countries_by_code
        @_countries_by_code ||= Country.pluck(:country_code).to_set
      end

      def find_holidays_matching_date_range(raw_holiday)
        super.where(country_code: raw_holiday.country_code)
      end

      def raw_holiday_valid?(raw_holiday)
        errors = []
        errors.push("Country doesnt exist") unless countries_by_code.include?(raw_holiday.country_code)
        update_state(raw_holiday, :error, nil, errors) && (return false) unless errors.empty?
        true
      end

      # def day_attributes(date)
      #   {date: date.send(holiday_expr.calendar_type), holiday_id: holiday.id}
      # rescue ArgumentError
      #   nil
      # end

      def holiday_from_raw(raw_holiday, holiday = nil)
        holiday ||= Holiday.new
        source_ids = holiday&.source_ids || {}
        merge_args = {
          'holiday_expr_id' => raw_holiday.id,
          'source_ids' => source_ids.deep_merge(self.class::SOURCE => raw_holiday.ids.keys.map(&:to_i)),
          'current_source_type' => Holiday.current_source_types[self.class::SOURCE]
        }
        holiday.assign_attributes(raw_holiday.attributes.slice(*self.class::HOLIDAY_FIELDS).merge(merge_args))
        holiday
      end

      def update_state(raw_holiday, _state, _holiday_id, _errors = [])
        raw_holiday.assign_attributes(processed: true)
        raw_holidays.push raw_holiday
      end
    end
  end
end
