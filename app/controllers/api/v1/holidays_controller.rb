module Api
  module V1
    class HolidaysController < ::ApplicationController
      HOLIDAY_EXPR_PARAMS = %i[ja_name en_name country_code expression calendar_type holiday_type].freeze

      before_action :authorize_user
      before_action :find_holiday, only: %i[update destroy move]

      def index
        render_response { HolidaysService.new(params).call }
      end

      def create
        render_response { HolidayExpr.create!(params.permit(*HOLIDAY_EXPR_PARAMS)) }
      end

      def update
        render_response { @holiday.update!(params.permit(*HOLIDAY_EXPR_PARAMS)) }
      end

      def destroy
        render_response { @holiday.destroy }
      end

      def move
        render_response { @holiday.days.find_by(date: params[:from]).move_to(params[:to]) }
      end

      private

      def authorize_user
        authorize %i[holiday]
      end

      def find_holiday
        @holiday ||= Holiday.find(params[:id])
      end
    end
  end
end
