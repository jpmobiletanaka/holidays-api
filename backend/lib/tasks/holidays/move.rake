# rubocop:disable Metrics/LineLength
namespace :holidays do
  namespace :move do
    desc 'Move holidays in 2020 because of Olympics'
    task in2020: :environment do
      Day.joins(:holiday).find_by(date: Date.civil(2020, 7, 20), holidays: { country_code: :jp, en_name: 'Marine Day' }).move_to(Date.civil(2020, 7, 23))
      Day.joins(:holiday).find_by(date: Date.civil(2020, 10, 12), holidays: { country_code: :jp, en_name: 'Health and Sports Day' }).move_to(Date.civil(2020, 6, 24))
      Day.joins(:holiday).find_by(date: Date.civil(2020, 8, 11), holidays: { country_code: :jp, en_name: 'Mountain Day' }).move_to(Date.civil(2020, 8, 10))
    end
  end
end
# rubocop:enable Metrics/LineLength
