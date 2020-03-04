User.create(
  email: Rails.application.credentials.admin_user,
  password: Rails.application.credentials.admin_password,
  admin: true
)
