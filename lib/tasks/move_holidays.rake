# rubocop:disable Metrics/LineLength
namespace :holidays do
  namespace :move do
    desc 'Move holidays in 2020 because of Olympics'
    task in_2020: :environment do
      Holiday.by_country_code(:jp).by_date(Date.civil(2020, 7, 20)).by_name('Marine Day').first.move_to(Date.civil(2020, 7, 23))
      Holiday.by_country_code(:jp).by_date(Date.civil(2020, 10, 12)).by_name('Health and Sports Day').first.move_to(Date.civil(2020, 6, 24))
      Holiday.by_country_code(:jp).by_date(Date.civil(2020, 8, 11)).by_name('Mountain Day').first.move_to(Date.civil(2020, 8, 10))
    end
  end
end
# rubocop:enable Metrics/LineLength
