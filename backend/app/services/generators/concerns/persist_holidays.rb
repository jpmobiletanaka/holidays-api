module Generators
  module Concerns
    module PersistHolidays
      private

      def raw_holidays
        @_raw_holidays ||= []
      end

      def days
        @_days ||= []
      end

      def destroy_old_holidays
        holidays_to_destroy.map(&:destroy!)
      end

      def save_holidays
        holidays_to_create.merge(holidays_to_update).each do |holiday, raw_holiday|
          holiday.save!

          raw_holiday.extracted_dates.map do |date|
            days.push(Day.new(date: date.send(raw_holiday.calendar_type), holiday_id: holiday.id))
          end

          update_state(raw_holiday, :success, holiday.id)
        end
      end

      def save_days
        Day.import!(days, on_duplicate_key_ignore: true, validate: false)
      end

      def save_raw_holidays
        raw_holiday_class.import(expanded_raw_holidays, on_duplicate_key_update: %i[state error holiday_id],
                                 validate: false)
      end

      def update_state(raw_holiday, state, holiday_id, errors = [])
        raw_holiday.assign_attributes(state: state, holiday_id: holiday_id, error: [*errors].compact.presence)
        raw_holidays.push raw_holiday
      end

      def expanded_raw_holidays
        raw_holidays.each_with_object([]) do |grouped_raw_holiday, res|
          grouped_raw_holiday.ids.each do |id, date|
            holiday = grouped_raw_holiday.attributes.slice(*self.class::RAW_HOLIDAY_FIELDS)
                        .merge(id: id, date: date, ja_name: grouped_raw_holiday.ja_names.first)
            res.push(holiday)
          end
        end
      end
    end
  end
end
