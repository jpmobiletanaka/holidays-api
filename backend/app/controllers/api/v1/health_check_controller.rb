module Api
  module V1
    class HealthCheckController < ApplicationController
      skip_before_action :authenticate_user

      def index
        head :ok
      end
    end
  end
end
