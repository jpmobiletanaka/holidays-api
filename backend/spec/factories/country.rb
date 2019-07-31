FactoryBot.define do
  factory :country do
    ja_name { I18n.with_locale(:ja) { Faker::Name.name } }
    en_name { Faker::Name.name }
    country_code { en_name.first(2) }
  end
end