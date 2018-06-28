module Api
  module V1
    class HolidaysController < ApplicationController
      def index
        render_response { HolidaysService.new(params).call }
      end
    end
  end
end
