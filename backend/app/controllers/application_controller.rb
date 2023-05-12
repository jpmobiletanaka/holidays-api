class NotAuthenticatedError < StandardError; end

class ApplicationController < ActionController::API
  include ErrorHandler
  include Authable
  include Pundit::Authorization

  protected

  def render_response(status: :ok)
    render json: yield, status: status
  end
end
