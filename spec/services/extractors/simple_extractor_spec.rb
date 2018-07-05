require 'rails_helper'

RSpec.describe Extractors::SimpleExtractor do
  let(:month) { Faker::Number.between(1, 12).to_i }
  let(:day) { Faker::Number.between(1, 28).to_i }
  let(:holiday_expr) { create(:holiday_expr, expression: "#{month}/#{day}") }
  let(:period) { Faker::Number.between(1990, 2005).to_i..Faker::Number.between(2005, 2020).to_i }

  subject(:dates) { described_class.new(holiday_expr, period).call }

  it { expect(dates.count).to eq period.count }
  it { expect(dates.all? { |date| date.month == month && date.day == day }).to be true }
end
