module Api
  module V1
    class AuthController < ::ApplicationController
      skip_before_action :authenticate_user

      def create
        render_response do
          token_command = Auth::GenerateUserTokenCommand.call(*params.slice(:email, :password).values)
          raise NotAuthenticatedError unless token_command.success?
          { token: token_command.result }
        end
      end
    end
  end
end
