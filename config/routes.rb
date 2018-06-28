require 'sidekiq/web'

Rails.application.routes.default_url_options[:host] = ENV['HOST'] if ENV['HOST']
Rails.application.routes.default_url_options[:port] = ENV['PORT'] if ENV['PORT'] && Rails.env.development?

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :auth, only: %i[create]
      resources :holidays, only: %i[index] do
        collection do
          get ':country_code', action: :index
          get ':country_code/:year', action: :index
        end
      end
    end
  end
end
