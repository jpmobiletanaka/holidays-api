require 'rails_helper'

RSpec.describe Extractors::MoonExtractor do
  let(:month) { Faker::Number.between(1, 12).to_i }
  let(:period) { Faker::Number.between(1990, 2005).to_i..Faker::Number.between(2005, 2020).to_i }
  let(:holiday_expr) { create(:holiday_expr, expression: "#{month}/full-moon") }
  let(:dates_count) { period.map { |year| FullMoonService.in(year, month).count }.sum }

  subject(:dates) { described_class.new(holiday_expr, period).call }

  it { expect(dates.count).to eq dates_count }
  it { expect(dates.all? { |date| date.month == month }).to be true }
end
