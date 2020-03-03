FactoryBot.define do
  factory :google_raw_holiday do
    country_code { jp }
    en_name { 'Christmas' }
    ja_name { 'クリスマス' }
    observed { false }
    date { '2020-01-07' }
    state { 'pending' }
  end
end
