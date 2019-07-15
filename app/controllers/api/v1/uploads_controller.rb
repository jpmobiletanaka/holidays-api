module Api
  module V1
    class UploadsController < ::ApplicationController
      def create
        res = ProcessFileService.call(file: params[:file], user: current_user)
        render_response(status: res.delete(:status)) { res }
      end
    end
  end
end
