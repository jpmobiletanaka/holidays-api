namespace :holidays do
  desc 'Import HolidayExpr from all sources'
  task import: :environment do
    ImportJob.perform_later
  end
end
