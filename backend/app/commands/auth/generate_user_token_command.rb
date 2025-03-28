module Auth
  class GenerateUserTokenCommand < ::BaseCommand
    private

    attr_reader :email, :password

    def initialize(email, password)
      @email    = email
      @password = password
    end

    def user
      @user ||= User.find_by(email: email)
    end

    def payload
      if password_valid?
        @result = JwtService.encode(contents)
      else
        errors.add(:base, I18n.t('auth.invalid_credentials'))
      end
    end

    def password_valid?
      user&.authenticate(password)
    end

    def contents
      {
        id: user.id,
        email: user.email,
        exp: 24.hours.from_now.to_i
      }
    end
  end
end
