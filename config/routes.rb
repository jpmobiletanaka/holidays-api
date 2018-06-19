require 'sidekiq/web'

Rails.application.routes.default_url_options[:host] = ENV['HOST'] if ENV['HOST']
Rails.application.routes.default_url_options[:port] = ENV['PORT'] if ENV['PORT'] && Rails.env.development?

Rails.application.routes.draw do
  # authenticate :user, ->(user) { user.admin? } do
  mount Sidekiq::Web => '/jobs'
  # end
end
