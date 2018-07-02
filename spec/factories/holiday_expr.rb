FactoryBot.define do
  factory :holiday_expr do
    ja_name { I18n.with_locale(:ja) { Faker::Name.name } }
    en_name { Faker::Name.name }
    country
    expression { Date.current.strftime('%m/%d') }
    calendar_type { :gregorian }
    holiday_type { :holiday }
    processed { false }
  end
end