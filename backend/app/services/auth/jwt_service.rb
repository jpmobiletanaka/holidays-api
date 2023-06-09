module Auth
  class JwtService
    ALGORITHM  = 'HS256'.freeze
    SECRET_KEY = ENV.fetch('JWT_SECRET_KEY')

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
