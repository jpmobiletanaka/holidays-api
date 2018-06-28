module Authable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user
    attr_reader :current_user
  end

  private

  def authenticate_user
    @current_user = Auth::FindUserCommand.call(request.headers).result
    raise NotAuthenticatedError unless current_user
  end
end