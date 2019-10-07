require "google_holiday_calendar"

module Fetchers
  class FetchFromGoogleService < ::Fetchers::BaseFetcherService
    DEFAULT_LIMIT = 500
    GOOGLE_CALENDAR_API_KEY = Rails.application.credentials.google_calendar_api_key

    def initialize(**args)
      super
      @country         = options[:country]
      @start_date      = start_date || Date.current.beginning_of_year
      @end_date        = end_date || Date.current.end_of_year
      @calendar_events = langs.zip(Array.new(langs.size)).to_h
    end

    def call
      fetch
      transform
      import
      self
    end

    private

    attr_reader :langs, :options, :country, :calendar_events, :transformed_events, :start_date, :end_date

    def fetch
      langs.each do |lang|
        calendar = GoogleHolidayCalendar::Calendar.new(country: country.google_calendar_id,
                                                       lang: lang,
                                                       api_key: GOOGLE_CALENDAR_API_KEY)
        @calendar_events[lang] = calendar.holidays(start_date: start_date, end_date: end_date, limit: DEFAULT_LIMIT)
      end
    end

    def transform
      events = calendar_events.each_with_object({}) do |(key, value), result|
        event_hash = value.each_with_object({}) do |(date, event), hsh|
          hsh[date] = generate_event_hash(date, event, key)
        end

        result.merge!(event_hash) do |_, old_v, new_v|
          old_v.merge(new_v)
        end
      end.values

      @transformed_events =
        events.group_by { |event| event.slice(*grouping_key) }
              .each_with_object([]) do |(_, events_group), res|
                res.push(*MergeEventGroupService.call(events: events_group))
              end
    end

    def import
      HolidayExpr.import!(transformed_events, on_duplicate_key_ignore: true, validate: false)
    end

    def generate_event_hash(date, event, lang)
      { country_code: country.country_code, calendar_type: calendar_type(event),
        date_hash: { year: date.year, month: date.month, day: date.day }, "#{lang}_name": event }
    end

    def grouping_key
      @_grouping_key ||= langs.map { |l| :"#{l}_name" }
    end

    def calendar_type(_)
      :gregorian
    end
  end
end
