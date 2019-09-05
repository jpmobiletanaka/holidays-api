# frozen_string_literal: true
module Fetchers
  class S3FetcherService < BaseFetcherService
    REGION = ENV.fetch('AWS_REGION') { 'ap-northeast-1' }
    BUCKET = ENV.fetch('HOLIDAYS_API_BUCKET') { 'revenue-staging-uploads' }
    DATE_KEY = 'Date'
    EN_COUNTRY_KEY = 'Country'
    JA_COUNTRY_KEY = nil
    EN_NAME_KEY = 'Holiday name'
    JA_NAME_KEY = 'Holiday name (ja)'

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
    rescue => e
      error(e)
    end

    attr_reader :invalid_rows

    private

    def success
      upload.update! status: Upload.statuses[:success]
      super
    end

    def error(e)
      upload.update! status: Upload.statuses[:error]
      super
    end

    attr_reader :options, :upload, :file_body, :countries, :transformed_events

    def fetch_file
      @file_body = upload.file.read
    end

    def transform
      data = CSV.parse file_body, headers: true

      events = data.each_with_object([]) do |row, res|
        country = find_country(row)
        invalid_rows.push(row) && next unless country
        res.push generate_row_hash(row, country)
      end

      @transformed_events = events.group_by{ |row| grouping_key(row) }
                                  .each_with_object([]) do |(_, row_group), res|
        res.push *MergeEventGroupService.call(events: row_group)
      end
    end

    def import
      HolidayExpr.import!(transformed_events, on_duplicate_key_ignore: true, validate: false)
    end

    def generate_row_hash(row, country)
      date_hash = %i(month day year).zip(row[DATE_KEY].split('/')).to_h
      { country_code: country.country_code, calendar_type: calendar_type(row),
        date_hash: date_hash, en_name: row[EN_NAME_KEY], ja_name: row[JA_NAME_KEY] }
    end

    def find_country(row)
      countries[row[EN_COUNTRY_KEY]] ||= Country.find_by(en_name: row[EN_COUNTRY_KEY])
    end

    def grouping_key(row)
      [row[:country_code], row[:en_name]]
    end

    def calendar_type(_)
      :gregorian
    end
  end
end
