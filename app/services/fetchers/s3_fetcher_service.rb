# frozen_string_literal: true
module Fetchers
  class S3FetcherService < BaseFetcherService
    REGION = ENV.fetch('AWS_REGION') { 'ap-northeast-1' }
    BUCKET = ENV.fetch('HOLIDAYS_API_BUCKET') { 'revenue-staging-uploads' }
    EN_NAME_KEY = 'Holiday name'
    JA_NAME_KEY = 'Holiday name (ja)'

    def initialize(**args)
      super
      @s3           = Aws::S3::Resource.new region: REGION
      @countries    = {}
      @invalid_rows = []
    end

    def call
      fetch_file
      transform
      import
      success
    rescue => e
      binding.pry
      error(e)
    end

    private

    attr_reader :options, :s3, :file_body, :countries, :invalid_rows, :transformed_events

    def fetch_file
      obj = s3.bucket(BUCKET).object(options[:object_key])
      @file_body = obj.get.body.read
    end

    def transform
      data = CSV.parse file_body, headers: true

      events = data.each_with_object([]) do |row, res|
        country = countries[row['Country']] ||= Country.find_by(en_name: row['Country'])
        invalid_rows.push(row) && next unless country
        res.push generate_row_hash(row, country)
      end

      @transformed_events = events.group_by{ |row| grouping_key(row) }
                                  .each_with_object([]) do |(_, row_group), res|
        res.push *MergeEventGroupService.call(events: row_group)
      end
    end

    def import
      binding.pry
      HolidayExpr.import!(transformed_events, on_duplicate_key_ignore: true, validate: false)
    end

    def generate_row_hash(row, country)
      date_hash = %i(year month day).zip(row['DATE'].split('/')).to_h
      { country_code: country.country_code, calendar_type: calendar_type(row),
        date_hash: date_hash, en_name: row[EN_NAME_KEY], ja_name: row[JA_NAME_KEY] }
    end

    def grouping_key(row)
      [row[:country_code], row[:en_name]]
    end

    def calendar_type(_)
      :gregorian
    end
  end
end
