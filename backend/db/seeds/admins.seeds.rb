password = SecureRandom.urlsafe_base64(nil, false)

user = User.new(
  email: "admin@holidays-api.com",
  password: password,
  admin: true
)

unless User.exists?(email: user.email)
  user.save
  puts ({ user.email => user.password })
end
