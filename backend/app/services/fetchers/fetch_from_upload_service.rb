# frozen_string_literal: true

module Fetchers
  class FetchFromUploadService < ::Fetchers::BaseFetcherService
    REGION = ENV.fetch('AWS_REGION') { 'ap-northeast-1' }
    BUCKET = ENV.fetch('HOLIDAYS_API_BUCKET') { 'revenue-staging-uploads' }
    DATE_KEY = 'date'
    EN_COUNTRY_KEY = 'country'
    JA_COUNTRY_KEY = nil
    EN_NAME_KEY = 'en_name'
    JA_NAME_KEY = 'ja_name'
    DAY_OFF_KEY = 'day_off'
    OBSERVED_KEY = 'observed'
    MOVED_FROM_KEY = 'moved_from'
    UPSERT_KEYS = %i[en_name date country observed].freeze

    def initialize(**args)
      super
      @countries    = {}
      @upload       = Upload.find(options[:upload_id])
      @invalid_rows = []
    end

    def call
      fetch_file
      transform
      import
      success
    rescue StandardError => e
      error(e)
    end

    private

    attr_reader :options, :upload, :file_body, :countries, :events, :invalid_rows

    def success
      upload.update! status: Upload.statuses[:success]
      super
    end

    def error(e)
      upload.update! status: Upload.statuses[:error]
      super
    end

    def fetch_file
      @file_body = upload.file.read
    end

    def transform
      data = CSV.parse file_body, headers: true
      @events = data.each_with_object([]) do |row, res|
        res.push generate_row_hash(row)
      end
    end

    def uniq_events
      events.uniq { |e| e.slice(*UPSERT_KEYS) }
    end

    def import
      FileRawHoliday.import!(uniq_events, on_duplicate_key_update: { conflict_target: UPSERT_KEYS,
                                                                     columns: %i[moved_from day_off] }, validate: false)
    end

    def generate_row_hash(row)
      {
        country: row[EN_COUNTRY_KEY],
        date: Date.parse(row[DATE_KEY]),
        en_name: row[EN_NAME_KEY].strip,
        ja_name: row[JA_NAME_KEY].strip,
        observed: row[OBSERVED_KEY].to_bool,
        moved_from: moved_from(row[MOVED_FROM_KEY]),
        day_off: row[DAY_OFF_KEY].to_bool
      }
    end

    def moved_from(val)
      Date.parse(val) rescue nil
    end

    def find_country(row)
      countries[row[EN_COUNTRY_KEY]] ||= Country.find_by(en_name: row[EN_COUNTRY_KEY])
    end

    def calendar_type(_)
      :gregorian
    end
  end
end
