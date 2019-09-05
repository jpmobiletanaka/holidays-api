FactoryBot.define do
  factory :upload do
    association :user
    file nil
    status 0
    type ""
  end
end
