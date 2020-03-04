module Api
  module V1
    class HolidaysController < ::ApplicationController
      HOLIDAY_EXPR_PARAMS = %i[ja_name en_name country_code expression calendar_type
                               holiday_type observed recurring day_off].freeze

      before_action :authorize_user
      before_action :find_holiday, only: %i[update destroy move]

      def index
        render_response { HolidaysService.new(params).call }
      end

      def show
        render_response { Holiday.find(params[:id]).holiday_expr }
      end

      def create
        render_response { HolidayExpr.create!(holiday_params) }
      end

      def update
        render_response do
          @holiday.holiday_expr.update!(holiday_params.to_h.merge(processed: false))
        end
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

      def holiday_params
        params.permit(*HOLIDAY_EXPR_PARAMS).tap do |permitted|
          permitted.delete(:calendar_type) if permitted[:calendar_type].blank?
          permitted[:holiday_type] = :holiday
        end
      end
    end
  end
end
