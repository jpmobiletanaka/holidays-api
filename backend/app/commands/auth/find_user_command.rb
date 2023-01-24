module Auth
  class FindUserCommand < ::BaseCommand
    private

    attr_reader :headers

    def initialize(headers)
      @headers = headers
      @user    = nil
    end

    def payload
      return unless token.present? && token_contents.present? && user.present?

      @result = user
    end

    def user
      @user ||= begin
        user = User.find_by(token_contents.slice('id', 'email'))
        return user if user.present?

        errors.add(:token, I18n.t('auth.token_invalid'))
        nil
      end
    end

    def token
      headers.env['HTTP_AUTHORIZATION'].to_s.gsub('Bearer ', '')
    rescue NoMethodError
      errors.add(:token, I18n.t('auth.token_missing'))
      nil
    end

    def token_contents
      @token_contents ||= begin
        decoded = JwtService.decode(token)
        return decoded if decoded.present?

        errors.add(:token, I18n.t('auth.token_expired'))
        nil
      end
    end
  end
end
