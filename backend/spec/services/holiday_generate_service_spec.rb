require 'rails_helper'

RSpec.describe HolidayGenerateService do
  subject(:service) { described_class.new(holiday_expr, params) }

  let(:years_period) { 1995..2005 }
  let(:params) { { start_date: years_period.first, end_date: years_period.last } }

  let(:day) { Faker::Number.between(1, 28) }
  let(:month) { Faker::Number.between(1, 12) }
  let(:year) { Faker::Number.between(1970, 2038) }

  let(:day_from) { Faker::Number.between(1, 10) }
  let(:day_to) { Faker::Number.between(10, 20) }
  let(:period_days) { day_from..day_to }

  let(:month_from) { Faker::Number.between(1, 2) }
  let(:month_to) { Faker::Number.between(3, 4) }
  let(:period_months) { month_from..month_to }

  let(:nth) { [-2, -1, 1, 2, 3, 4].sample }
  let(:day_of_week) { Faker::Number.between(1, 7) }

  describe '#call' do
    let(:holiday_expr) { create(:holiday_expr) }

    it { expect { service.call }.to change { holiday_expr.reload.processed }.from(false).to(true) }
  end

  context 'with year' do
    context 'simple' do
      let(:holiday_expr) { create(:holiday_expr, expression: "#{year}/#{month}/#{day}") }

      it { expect { service.call }.to change(Holiday, :count).from(0).to(1) }
      it { expect { service.call }.to change(Day, :count).from(0).to(1) }
    end

    context 'moon' do
      let(:holiday_expr) { create(:holiday_expr, expression: "#{year}/#{month}/full-moon") }

      it { expect { service.call }.to change(Holiday, :count).from(0).to(1) }
      it { expect { service.call }.to change(Day, :count).from(0).to(1) }
    end

    context 'nth' do
      let(:holiday_expr) { create(:holiday_expr, expression: "#{year}/#{month}/#{nth},#{day_of_week}") }

      it { expect { service.call }.to change(Holiday, :count).from(0).to(1) }
      it { expect { service.call }.to change(Day, :count).from(0).to(1) }
    end

    context 'period' do
      let(:holiday_expr) { create(:holiday_expr, expression: "#{year}/#{month}/#{day_from}-#{day_to}") }

      it { expect { service.call }.to change(Holiday, :count).from(0).to(1) }
      it { expect { service.call }.to change(Day, :count).from(0).to(period_days.count) }
    end

    context 'large period' do
      let(:holiday_expr) { create(:holiday_expr, expression: "#{year}/(#{month_from}/#{day_from})-(#{month_to}/#{day_to})") }
      let(:count) { (Date.civil(year, month_from, day_from)..Date.civil(year, month_to, day_to)).count }

      it { expect { service.call }.to change(Holiday, :count).from(0).to(1) }
      it { expect { service.call }.to change(Day, :count).from(0).to(count) }
    end
  end

  context 'without year' do
    context 'simple' do
      let(:holiday_expr) { create(:holiday_expr, expression: "#{month}/#{day}") }
      let(:count) { Extractors::SimpleExtractor.new(holiday_expr, years_period).call.count }

      it { expect { service.call }.to change(Holiday, :count).from(0).to(1) }
      it { expect { service.call }.to change(Day, :count).from(0).to(count) }
    end

    context 'moon' do
      let(:holiday_expr) { create(:holiday_expr, expression: "#{month}/full-moon") }
      let(:count) { Extractors::MoonExtractor.new(holiday_expr, years_period).call.count }

      it { expect { service.call }.to change(Holiday, :count).from(0).to(1) }
      it { expect { service.call }.to change(Day, :count).from(0).to(count) }
    end

    context 'nth' do
      let(:holiday_expr) { create(:holiday_expr, expression: "#{month}/#{nth},#{day_of_week}") }
      let(:count) { Extractors::NthExtractor.new(holiday_expr, years_period).call.count }

      it { expect { service.call }.to change(Holiday, :count).from(0).to(1) }
      it { expect { service.call }.to change(Day, :count).from(0).to(count) }
    end

    context 'period' do
      let(:holiday_expr) { create(:holiday_expr, expression: "#{month}/#{day_from}-#{day_to}") }
      let(:count) { Extractors::PeriodExtractor.new(holiday_expr, years_period).call.count }

      it { expect { service.call }.to change(Holiday, :count).from(0).to(1) }
      it { expect { service.call }.to change(Day, :count).from(0).to(count) }
    end

    context 'large period' do
      let(:holiday_expr) { create(:holiday_expr, expression: "(#{month_from}/#{day_from})-(#{month_to}/#{day_to})") }
      let(:count) { Extractors::LargePeriodExtractor.new(holiday_expr, years_period).call.count }

      it { expect { service.call }.to change(Holiday, :count).from(0).to(1) }
      it { expect { service.call }.to change(Day, :count).from(0).to(count) }
    end
  end
end
