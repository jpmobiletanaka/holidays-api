module Generators
  module Concerns
    module ValidateHolidays
      def raw_holiday_valid?(_raw_holiday)
        raise NotImplementedError
      end

      def priority_allows_update?(holidays)
        holidays.all? do |h|
          h.read_attribute_before_type_cast(:current_source_type) >= Holiday.current_source_types[self.class::SOURCE]
        end
      end

      def holidays_valid?(holidays, grouped_raw_holiday)
        return true if holidays.empty?
        return true if priority_allows_update?(holidays)
        update_state(grouped_raw_holiday, :success, holidays.first.id, 'Higher priority holidays found for this source')
        false
      end
    end
  end
end
