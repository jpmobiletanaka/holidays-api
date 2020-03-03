FactoryBot.define do
  factory :holiday do
    transient do
      dates {}
    end

    after(:create) do |holiday, evaluator|
      if evaluator.dates.present?
        evaluator.dates.each do |day|
          create :day, date: day, holiday: holiday
        end
      else
        create_list :day, 2
      end
    end
  end
end
