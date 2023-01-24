require 'rails_helper'

RSpec.describe Extractors::NthExtractor do
  let(:month) { Faker::Number.between(from: 1, to: 12).to_i }
  let(:period) { Faker::Number.between(from: 1990, to: 2005).to_i..Faker::Number.between(from: 2005, to: 2020).to_i }
  let(:nth) { [-2, -1, 1, 2, 3, 4].sample }
  let(:day_of_week) { Faker::Number.between(from: 1, to: 7) }
  let(:holiday_expr) { create(:holiday_expr, expression: "#{month}/#{nth},#{day_of_week}") }

  subject(:dates) { described_class.new(holiday_expr, period).call }

  it { expect(dates.count).to eq period.count }
  it { expect(dates.all? { |date| date.month == month }).to be true }
  it { expect(dates.all? { |date| date.cwday == day_of_week }).to be true }
end
