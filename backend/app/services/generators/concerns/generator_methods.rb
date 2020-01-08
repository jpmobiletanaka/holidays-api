# frozen_string_literals: true
# rubocop:disable Metrics/ModuleLength

module Generators
  module Concerns
    module GeneratorMethods
      extend ActiveSupport::Concern
      include ActiveRecord::Sanitization::ClassMethods

      def call
        unprocessed_holidays do |grouped_raw_holiday|
          next unless raw_holiday_valid?(grouped_raw_holiday)

          holidays = find_holidays_matching_date_range(grouped_raw_holiday)
          next unless holidays_valid?(holidays, grouped_raw_holiday)

          process_holidays(holidays.to_a, grouped_raw_holiday)
        end

        ActiveRecord::Base.transaction do
          destroy_old_holidays
          save_holidays
          save_days
          save_raw_holidays
        end
      end

      private

      def raw_holidays
        @_raw_holidays ||= []
      end

      def days
        @_days ||= []
      end

      def holidays_to_update
        @_holidays_to_update ||= {}
      end

      def holidays_to_create
        @_holidays_to_create ||= {}
      end

      def holidays_to_destroy
        @_holidays_to_destroy ||= []
      end

      def find_holidays_matching_date_range(raw_holiday)
        Holiday.eager_load(:days)
               .select('holidays.*',
                       Holiday.sanitize_sql_array(["SIMILARITY(holidays.en_name, ?) AS smt", raw_holiday.en_name]))
               .where('SIMILARITY(holidays.en_name, :en_name) > :smt',
                      en_name: raw_holiday.en_name,
                      smt: self.class::SIMILARITY_THRESHOLD)
               .where(":daterange::daterange @> days.date",
                      daterange: "[#{raw_holiday.min_date}, #{raw_holiday.max_date}]")
               .where(observed: raw_holiday.observed)
      end

      def unprocessed_holidays
        sql = <<~SQL
          WITH sequenced_holidays AS (
            WITH partitioned_holidays AS ( SELECT *, date - LAG(date, 1) OVER (w) > 1 AS new_holiday_date FROM #{raw_holiday_class.table_name}
              WINDOW w AS (PARTITION BY #{self.class::PARTITION_FIELDS.join(', ')} ORDER BY date) )
            SELECT *, COALESCE(SUM(CASE WHEN new_holiday_date THEN 1 END) OVER (w2), 0) holiday_seq FROM partitioned_holidays
              WINDOW w2 AS (PARTITION BY #{self.class::PARTITION_FIELDS.join(', ')} ORDER BY date)
           )
            SELECT JSONB_OBJECT_AGG(id, date) AS ids, #{self.class::COUNTRY_FIELD.to_s}, en_name, observed, MIN(date) AS min_date,
                   MAX(date) AS max_date, JSON_AGG(DISTINCT ja_name) AS ja_name, holiday_seq
            FROM sequenced_holidays
            WHERE state = 'pending'
            GROUP BY #{self.class::COUNTRY_FIELD.to_s}, en_name, holiday_seq, observed
        SQL

        raw_holiday_class.find_by_sql(sql).each do |holiday|
          yield ::GroupedRawHoliday.new(holiday)
        end
      end

      def priority_allows_update?(holidays)
        holidays.all? do |h|
          h.read_attribute_before_type_cast(:current_source_type) >= Holiday.current_source_types[self.class::SOURCE]
        end
      end

      def holidays_from_raw(raw_holiday, holiday = nil)
        holiday ||= Holiday.new
        source_ids = holiday.source_ids || {}
        merge_args = {
          'ja_name' => raw_holiday.ja_names.first,
          'source_ids' => source_ids.deep_merge(self.class::SOURCE => raw_holiday.ids.keys.map(&:to_i)),
          'current_source_type' => Holiday.current_source_types[self.class::SOURCE]
        }
        holiday.assign_attributes(raw_holiday.attributes.slice(*self.class::HOLIDAY_FIELDS).merge(merge_args))
        holiday
      end

      def process_holidays(holidays, raw_holiday)
        existing_holiday = holidays.shift

        if existing_holiday
          holidays_to_update.merge!(holidays_from_raw(raw_holiday, existing_holiday))
        else
          holidays_to_create.merge!(holidays_from_raw(raw_holiday))
        end

        holidays_to_destroy.push(*holidays)
      end

      def destroy_old_holidays
        holidays_to_destroy.map(&:destroy!)
      end

      def save_holidays
        holidays_to_create.merge(holidays_to_update).each do |holiday, raw_holiday|
          holiday.save!

          (raw_holiday.min_date..raw_holiday.max_date).map do |date|
            days.push(Day.new(date: date, holiday_id: holiday.id))
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

      def holidays_valid?(holidays, grouped_raw_holiday)
        return true if holidays.empty?
        return true if priority_allows_update?(holidays)
        update_state(grouped_raw_holiday, :success, holidays.first.id, 'Higher priority holidays found for this source')
        false
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
# rubocop:enable Metrics/ModuleLength
