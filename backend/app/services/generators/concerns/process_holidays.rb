module Generators
  module Concerns
    module ProcessHolidays
      private

      def holidays_to_update
        @_holidays_to_update ||= {}
      end

      def holidays_to_create
        @_holidays_to_create ||= {}
      end

      def holidays_to_destroy
        @_holidays_to_destroy ||= []
      end

      def process_holidays(holidays, raw_holiday)
        existing_holiday = holidays.shift
        holidays_to_destroy.push(*holidays)
        return handle_existing_holiday(existing_holiday, raw_holiday) if existing_holiday

        holidays_to_create[holiday_from_raw(raw_holiday)] = raw_holiday
      end

      def holiday_from_raw(raw_holiday, holiday = nil)
        holiday ||= Holiday.new
        source_ids = holiday&.source_ids || {}
        merge_args = {
          'ja_name' => raw_holiday.ja_names.first,
          'source_ids' => source_ids.deep_merge(self.class::SOURCE => raw_holiday.ids.keys.map(&:to_i)),
          'current_source_type' => Holiday.current_source_types[self.class::SOURCE]
        }
        holiday.assign_attributes(raw_holiday.attributes.slice(*self.class::HOLIDAY_FIELDS).merge(merge_args))
        holiday
      end

      def handle_existing_holiday(existing_holiday, raw_holiday)
        updated_holiday = holiday_from_raw(raw_holiday, existing_holiday)
        return holidays_to_update[updated_holiday] = raw_holiday if dates_match?(existing_holiday, raw_holiday)

        holidays_to_destroy.push existing_holiday
        holidays_to_create[holiday_from_raw(raw_holiday)] = raw_holiday
      end

      def dates_match?(existing_holiday, raw_holiday)
        existing_holiday.days.order(:date).pluck(:date) == raw_holiday.extracted_dates.to_a
      end
    end
  end
end
