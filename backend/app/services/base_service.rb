class BaseService
  def self.call(**args)
    Rails.logger.info JSON.dump(time: Time.now.utc, type: 'generate', class: self.class.name)
    args.present? ? new(**args).call : new.call
  end

  protected

  def success
    { state: :success }
  end

  def error(e)
    res = { state: :error, msg: e.message, status: :bad_request }
    res[:backtrace] = e.backtrace if Rails.env.development? || Rails.env.test?
    Rails.logger.error JSON.dump(time: Time.now.utc,
                                 class: self.class.name,
                                 error: res)
    res
  end
end
