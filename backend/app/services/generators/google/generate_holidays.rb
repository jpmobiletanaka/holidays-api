# frozen-string-literal: true

module Generators
  module Google
    class GenerateHolidays < BaseService
      include Generators::Concerns::FindBySimilarity
      include Generators::Concerns::ValidateHolidays
      include Generators::Concerns::ProcessHolidays
      include Generators::Concerns::ProcessAggregatedRawHolidays
      include Generators::Concerns::PersistHolidays

      SIMILARITY_THRESHOLD = 0.6
      SOURCE = :google
      RAW_HOLIDAY_FIELDS = %w[en_name observed state error holiday_id country_code].freeze
      HOLIDAY_FIELDS = %w[en_name observed country_code].freeze
      COUNTRY_FIELD = :country_code
      PARTITION_FIELDS = %w[country_code en_name observed].freeze

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
      rescue => e
        pp e.record.errors
        pp e.message
        pp e.backtrace
      end

      private

      def raw_holiday_class
        GoogleRawHoliday
      end

      def countries_by_code
        @_countries_by_code ||= Country.pluck(:country_code).to_set
      end

      def raw_holiday_valid?(raw_holiday)
        errors = []
        errors.push('Holiday has multiple Japanese names') unless raw_holiday.ja_names.size == 1
        errors.push("Country doesnt exist") unless countries_by_code.include?(raw_holiday.country_code)
        update_state(raw_holiday, :error, nil, errors) && (return false) unless errors.empty?
        true
      end

      def find_holidays_matching_date_range(raw_holiday)
        super.where(country_code: raw_holiday.country_code)
      end

      def holidays_from_raw(raw_holiday, existing_holiday = nil)
        holiday = super
        { holiday => raw_holiday }
      end
    end
  end
end
