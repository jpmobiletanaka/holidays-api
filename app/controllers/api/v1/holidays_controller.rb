module Api
  module V1
    class HolidaysController < ::ApplicationController
      before_action :authorize_user

      def index
        render_response { HolidaysService.new(params).call }
      end

      private

      def authorize_user
        authorize %i[holiday]
      end
    end
  end
end
