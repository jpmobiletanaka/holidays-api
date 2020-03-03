module Generators
  module Concerns
    module FindBySimilarity
      include ActiveRecord::Sanitization::ClassMethods

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
    end
  end
end

