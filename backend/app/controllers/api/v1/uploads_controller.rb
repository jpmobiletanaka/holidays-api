module Api
  module V1
    class UploadsController < ::ApplicationController
      def index
        render_response do
          Upload.where(user: current_user).last(100)
                .as_json(only: %i[id status created_at], methods: %i[file_info])
        end
      end

      def create
        res = ProcessFileService.call(file: params[:file], user: current_user)
        render_response(status: res.delete(:status)) { res }
      end
    end
  end
end
