namespace :holidays do
  desc 'Create holidays from HolidayExpr'
  task create: :environment do
    HolidayExpr.unprocessed.each(&:generate_holidays)
  end

  desc 'Recreating holidays from all HolidayExpr'
  task force_recreate: :environment do
    HolidayExpr.update_all(processed: false)
    Rake::Task['holidays:create'].execute
  end
end
