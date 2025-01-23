## Deploy backend
APP_NAME=holidays-api APP_ENV=production backend/deploy/deploy.sh
## Deploy frontend
APP_NAME=holidays-api APP_ENV=production frontend/deploy/deploy.sh
## Connect to server
  ./send_ssh_key.sh holidays-api-production-backend
  
### Fetch Holidays
```ruby
Country.all.each do |country|
  Fetchers::FetchFromGoogleService.call({ langs: [:en, :ja], options: { country: country }, start_date: '2026-01-01'.to_date})
end
Generators::Google::GenerateHolidays.call
```
