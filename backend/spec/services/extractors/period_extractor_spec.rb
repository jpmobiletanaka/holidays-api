require 'rails_helper'

RSpec.describe Extractors::PeriodExtractor do
  let(:month) { Faker::Number.between(from: 1, to: 12).to_i }
  let(:day_from) { Faker::Number.between(from: 1, to: 28).to_i }
  let(:day_to) { Faker::Number.between(from: 1, to: 28).to_i }
  let(:days_period) { day_from..day_to }
  let(:holiday_expr) { create(:holiday_expr, expression: "#{month}/#{day_from}-#{day_to}") }
  let(:period) { Faker::Number.between(from: 1990, to: 2005).to_i..Faker::Number.between(from: 2005, to: 2020).to_i }

  subject(:dates) { described_class.new(holiday_expr, period).call }

  it { expect(dates.count).to eq period.count * days_period.count }
  it { expect(dates.all? { |date| date.month == month && date.day.in?(days_period) }).to be true }
end
