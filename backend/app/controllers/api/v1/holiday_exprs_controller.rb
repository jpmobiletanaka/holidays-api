module Api
  module V1
    class HolidayExprsController < ::ApplicationController
      def show
        authorize %i[holiday]
        render_response { Holiday.find(params[:id]).to_json(methods: [:dates]) }
      end
    end
  end
end
