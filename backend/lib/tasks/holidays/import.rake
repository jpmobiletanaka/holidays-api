namespace :holidays do
  desc 'Import HolidayExpr from all sources'
  task import: :environment do
    Country.all.each do |country|
      ImportJob.perform_later('Fetchers::FetchFromGoogleService', { country: country })
    end
  end
end
