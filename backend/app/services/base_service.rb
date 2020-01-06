class BaseService
  def self.call(**args)
    args.present? ? new(**args).call : new.call
  end

  protected

  def success
    { state: :success }
  end

  def error(e)
    res = { state: :error, msg: e.message, status: :bad_request }
    res[:backtrace] = e.backtrace if Rails.env.development?
    res
  end
end
