# frozen-string-literal: true

module Generators
  module File
    class GenerateHolidays < BaseService
      include Generators::Concerns::GeneratorMethods

      SIMILARITY_THRESHOLD = 0.6
      SOURCE = :file
      RAW_HOLIDAY_FIELDS = %w[en_name observed state error holiday_id country].freeze
      HOLIDAY_FIELDS = %w[en_name observed day_off].freeze
      COUNTRY_FIELD = :country
      PARTITION_FIELDS = %w[country en_name observed].freeze

      private

      def raw_holiday_class
        FileRawHoliday
      end

      def countries_by_name
        @_countries_by_name ||= Country.pluck(:en_name, :country_code).to_h
      end

      def raw_holiday_valid?(raw_holiday)
        errors = []
        errors.push('Holiday has multiple Japanese names') unless raw_holiday.ja_names.size == 1
        errors.push("Country doesnt exist") unless countries_by_name.key?(raw_holiday.country)
        update_state(raw_holiday, :error, nil, errors) && (return false) unless errors.empty?
        true
      end

      def find_holidays_matching_date_range(raw_holiday)
        super.joins(:country).where(countries: { en_name: raw_holiday.country })
      end

      def holidays_from_raw(raw_holiday, existing_holiday = nil)
        holiday = super
        holiday.country_code = countries_by_name[raw_holiday.country]
        { holiday => raw_holiday }
      end
    end
  end
end
