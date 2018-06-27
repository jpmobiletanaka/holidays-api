class ApplicationController < ActionController::API
  rescue_from StandardError, with: :error_response

  protected

  def error_response(e)
    status = :bad_request
    status = :not_found if e.is_a? ActiveRecord::RecordNotFound
    render json: { error: e.message }, status: status
  end

  def render_response
    render json: yield, status: :ok
  end
end
