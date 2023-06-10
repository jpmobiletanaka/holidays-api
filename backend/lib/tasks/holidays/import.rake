namespace :holidays do
  desc 'Import HolidayExpr from all sources'
  task import: :environment do
    Country.all.each do |country|
      ImportJob.perform_later('Fetchers::FetchFromGoogleService', country: country)
    end
    # after saving the raw google holidays, import any new ones into the main holidays table
    Generators::Google::GenerateHolidays.call
  end
end
