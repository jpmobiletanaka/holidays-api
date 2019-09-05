User.create(
  email: Rails.application.credentials.admin_email,
  password: Rails.application.credentials.admin_password,
  admin: true
)