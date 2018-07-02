FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    admin false

    factory :admin, class: User do
      admin true
    end
  end
end