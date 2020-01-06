module Concerns
  module HolidaySource
    extend ActiveSupport::Concern

    included do
      belongs_to :holiday, optional: true
    end

    class_methods do
      def reset_state!
        update_all(state: :pending, error: nil, holiday_id: nil)
      end
    end
  end
end
