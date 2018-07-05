module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :error_response
  end

  private

  def error_response(e)
    case e
    when ActiveRecord::RecordNotFound
      status  = :not_found
      message = I18n.t('errors.not_found')
    when ActiveRecord::RecordInvalid
      status  = :bad_request
      message = e.message
    when NotAuthenticatedError, Pundit::NotAuthorizedError
      status  = :unauthorized
      message = I18n.t('errors.unauthorized')
    else
      status  = :bad_request
      message = I18n.t('errors.bad_request')
    end
    render json: { error: message }, status: status
  end
end