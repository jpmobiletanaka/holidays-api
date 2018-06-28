module Auth
  class JwtService
    ALGORITHM  = 'HS256'.freeze
    SECRET_KEY = Rails.application.credentials.jwt_secret_key

    def self.encode(payload)
      JWT.encode(payload, SECRET_KEY, ALGORITHM)
    end

    def self.decode(token)
      body, = JWT.decode(token, SECRET_KEY, true, algorithm: ALGORITHM)
      HashWithIndifferentAccess.new(body)
    rescue JWT::ExpiredSignature, JWT::DecodeError
      nil
    end
  end
end