require "google_holiday_calendar"

module Fetchers
  class GoogleFetcherService
    DEFAULT_LIMIT = 500

    def self.call(langs:, country:, start_date: Date.today.beginning_of_year, end_date: Date.today.end_of_year)
      new(langs, country, start_date, end_date).call
    end

    attr_reader :langs, :country, :start_date, :end_date, :events, :transformed_events

    def initialize(langs, country, start_date, end_date)
      @langs = langs
      @country = country
      @start_date = start_date
      @end_date = end_date
      @events = langs.zip(Array.new(langs.size)).to_h
    end

    def call
      fetch
      transform
      import
      self
    end

    private

    def fetch
      langs.each do |lang|
        calendar = GoogleHolidayCalendar::Calendar.new(country: country.google_calendar_id,
                                                       lang: lang,
                                                       api_key: ENV['GOOGLE_CALENDAR_API_KEY'])
        @events[lang] = calendar.holidays(start_date: start_date, end_date: end_date, limit: DEFAULT_LIMIT)
      end
    end

    def transform
      @transformed_events = events.each_with_object({}) do |(lang, events), res|
        events = events.each_with_object({}) do |(date, event), res|
          res[date] = generate_event_hash(date, event, lang)
        end

        res.merge!(events) do |_, old_v, new_v|
          old_v.merge(new_v)
        end
      end.values

      @transformed_events = transformed_events
                              .group_by { |event| event.slice(*names) }
                              .each_with_object([]) do |(_, events_group), res|
        expression = expression_from_dates(events_group.map { |event| event[:expression] })
        events_group = events_group.inject(&:merge)
        events_group[:expression] = expression
        res.push events_group
      end
    end

    def import
      HolidayExpr.import!(transformed_events, on_duplicate_key_ignore: true, validate: false)
    end

    def generate_event_hash(date, event, lang)
      { country_code: country.country_code, calendar_type: calendar_type(event),
        expression: { year: date.year, month: date.month, day: date.day }, "#{lang}_name": event }
    end

    def expression_from_dates(dates)
      return dates[0].values[1..-1].join('.') if dates.size == 1

      expression = if dates[0][:month] == dates[-1][:month]
        [dates[0][:month], "#{dates[0][:day]}-#{dates[-1][:day]}"].join('.')
      else
        "(#{dates[0][:month]}.#{dates[0][:day]})-(#{dates[-1][:month]}.#{dates[-1][:day]})"
                   end
      Rails.logger.info expression
      expression
    end

    def names
      @_names ||= langs.map { |l| :"#{l}_name" }
    end

    def calendar_type(_)
      :gregorian
    end
  end
end
