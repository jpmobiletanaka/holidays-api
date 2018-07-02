source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'

# common
gem 'bootsnap', '>= 1.1.0', require: false
gem 'puma', '~> 3.11'
gem 'rack-cors'
gem 'rails', '~> 5.2.0'
gem 'sidekiq', '~> 5.1', '>= 5.1.1'

# specific
gem 'lunartic'

# databases
gem 'activerecord-import'
gem 'mysql2', '~> 0.4.10'
gem 'redis', '~> 4.0.1'
gem 'seedbank'

# auth
gem 'bcrypt'
gem 'jwt'
gem 'pundit'

group :development, :test do
  gem 'bullet', git: 'https://github.com/k1r8r0wn/bullet.git'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails', '~> 4.8'
  gem 'faker'
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails', '~> 3.7'
  gem 'rubocop', require: false
  gem 'timecop'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
