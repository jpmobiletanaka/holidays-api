module Api
  module V1
    class CountriesController < ::ApplicationController
      COUNTRY_PARAMS = %i[ja_name en_name country_code].freeze

      before_action :authorize_user
      before_action :find_country, only: %i[update destroy]

      def index
        render_response { Country.available }
      end

      def create
        render_response { Country.create!(params.permit(*COUNTRY_PARAMS)) }
      end

      def update
        render_response { @country.update!(params.permit(*COUNTRY_PARAMS)) }
      end

      def destroy
        render_response { @country.destroy }
      end

      private

      def authorize_user
        authorize %i[country]
      end

      def find_country
        @country ||= Country.find(params[:id])
      end
    end
  end
end
