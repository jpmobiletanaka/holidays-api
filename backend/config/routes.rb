Rails.application.routes.default_url_options[:host] = ENV['HOST'] if ENV['HOST']
Rails.application.routes.default_url_options[:port] = ENV['PORT'] if ENV['PORT'] && Rails.env.development?

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get '/health-check', to: 'health_check#index'

      resources :auth, only: %i[create]

      resources :countries, only: %i[index create update destroy]

      resources :holiday_exprs, only: %i[show]
      resources :holidays, only: %i[index show create update destroy] do
        # collection do
        #   get ':country_code',       action: :index
        #   get ':country_code/:year', action: :index
        # end

        member do
          post :move
        end
      end

      resources :uploads, only: %i[index create]
    end
  end
end
