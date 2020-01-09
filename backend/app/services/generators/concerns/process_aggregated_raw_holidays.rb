module Generators
  module Concerns
    module ProcessAggregatedRawHolidays
      include Generators::Concerns::ProcessHolidays

      def process
        unprocessed_holidays do |grouped_raw_holiday|
          next unless raw_holiday_valid?(grouped_raw_holiday)

          holidays = find_holidays_matching_date_range(grouped_raw_holiday)
          next unless holidays_valid?(holidays, grouped_raw_holiday)

          process_holidays(holidays.to_a, grouped_raw_holiday)
        end
      end

      def unprocessed_holidays
        sql = <<~SQL
          WITH sequenced_holidays AS (
            WITH partitioned_holidays AS ( 
              SELECT *, date - LAG(date, 1) OVER (w) > 1 AS new_holiday_date FROM #{raw_holiday_class.table_name}
               WINDOW w AS (PARTITION BY #{self.class::PARTITION_FIELDS.join(', ')} ORDER BY date) 
            )
            SELECT *, COALESCE(SUM(CASE WHEN new_holiday_date THEN 1 END) OVER (w2), 0) holiday_seq FROM partitioned_holidays
              WINDOW w2 AS (PARTITION BY #{self.class::PARTITION_FIELDS.join(', ')} ORDER BY date)
          )
          SELECT JSONB_OBJECT_AGG(id, date) AS ids, 
                 #{self.class::COUNTRY_FIELD}, 
                 en_name, 
                 observed, 
                 MIN(date) AS min_date,
                 MAX(date) AS max_date, 
                 JSON_AGG(DISTINCT ja_name) AS ja_name, 
                 holiday_seq
          FROM sequenced_holidays
          WHERE state = 'pending'
          GROUP BY #{self.class::COUNTRY_FIELD}, en_name, holiday_seq, observed
        SQL

        raw_holiday_class.find_by_sql(sql).each do |holiday|
          yield ::GroupedRawHoliday.new(holiday)
        end
      end
    end
  end
end
