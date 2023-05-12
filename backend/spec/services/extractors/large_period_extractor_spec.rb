require 'rails_helper'

RSpec.describe Extractors::LargePeriodExtractor do
  let(:month_from) { Faker::Number.between(from: 1, to: 5).to_i }
  let(:month_to) { Faker::Number.between(from: 6, to: 12).to_i }
  let(:months_period) { month_from..month_to }
  let(:day_from) { Faker::Number.between(from: 1, to: 28).to_i }
  let(:day_to) { Faker::Number.between(from: 1, to: 28).to_i }
  let(:days_period) { day_from..day_to }
  let(:holiday_expr) { create(:holiday_expr, expression: "(#{month_from}/#{day_from})-(#{month_to}/#{day_to})") }
  let(:years_period) { Faker::Number.between(from: 1990, to: 2005).to_i..Faker::Number.between(from: 2005, to: 2020).to_i }

  subject(:dates) { described_class.new(holiday_expr, years_period).call }

  let(:dates_count) do
    years_period.map { |year| (Date.civil(year, month_from, day_from)..Date.civil(year, month_to, day_to)).count }.sum
  end

  it { expect(dates.count).to eq dates_count }
  it { expect(dates.all? { |date| date.month.in?(months_period) }).to be true }
end
