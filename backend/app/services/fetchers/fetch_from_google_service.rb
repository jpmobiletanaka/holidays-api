require "google_holiday_calendar"

module Fetchers
  class FetchFromGoogleService < ::Fetchers::BaseFetcherService
    DEFAULT_LIMIT = 500
    GOOGLE_CALENDAR_API_KEY = ENV.fetch('GOOGLE_CALENDAR_API_KEY')

    def initialize(**args)
      super
      @country         = options[:country]
      @start_date      = start_date || Date.current.beginning_of_year
      @end_date        = end_date || start_date.end_of_year + 1.year
      @raw_events      = langs.zip(Array.new(langs.size)).to_h
    end

    def call
      fetch
      transform
      import
      Rails.logger.info JSON.dump(time: Time.now.utc,
                                  class: self.class.name,
                                  start_date: start_date,
                                  end_date: end_date,
                                  events: events)
      self
    end

    private

    attr_reader :langs, :options, :country, :events, :raw_events, :transformed_events, :start_date, :end_date

    def fetch
      langs.each do |lang|
        calendar = GoogleHolidayCalendar::Calendar.new(country: country.google_calendar_id,
                                                       lang: lang,
                                                       api_key: GOOGLE_CALENDAR_API_KEY)
        @raw_events[lang] = calendar.holidays(start_date: start_date, end_date: end_date, limit: DEFAULT_LIMIT)
      end
    end

    def transform
      @events = raw_events.each_with_object({}) do |(lang, events_hsh), res|
        events_hsh = events_hsh.each_with_object({}) do |(date, event), acc|
          acc[date] = generate_event_hash(date, event, lang)
        end

        res.merge!(events_hsh) do |_, old_v, new_v|
          old_v.merge(new_v)
        end
      end.values
    end

    def import
      GoogleRawHoliday
        .import!(events, on_duplicate_key_update: { conflict_target: %i[en_name date country_code observed],
                                                    columns: %i[updated_at] }, validate: false)
    end

    def generate_event_hash(date, event, lang)
      hsh = { country_code: country.country_code, date: date, "#{lang}_name": event }
      hsh[:observed] = observed?(event) if lang.to_s == 'en'
      hsh
    end

    def observed?(event)
      event.include?('observed')
    end
  end
end
