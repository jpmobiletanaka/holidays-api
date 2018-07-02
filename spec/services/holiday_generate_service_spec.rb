require 'rails_helper'

RSpec.describe HolidayGenerateService do
  subject(:service) { described_class.new(holiday_expr, params) }

  let(:period) { 1995..2005 }
  let(:params) { { start_date: period.first, end_date: period.last } }

  let(:day) { Faker::Number.between(1, 28) }
  let(:month) { Faker::Number.between(1, 12) }

  let(:period_day_from) { Faker::Number.between(1, 10) }
  let(:period_day_to) { Faker::Number.between(10, 20) }
  let(:period_days) { period_day_from..period_day_to }

  let(:period_month_from) { Faker::Number.between(1, 2) }
  let(:period_month_to) { Faker::Number.between(3, 4) }
  let(:period_months) { period_month_from..period_month_to }

  describe '#call generates Holidays and set holiday_expr#processed: true' do
    let(:holiday_expr) { create(:holiday_expr) }

    it { expect { service.call }.to change(holiday_expr, :processed).from(false).to(true) }
    it { expect { service.call }.to change(Holiday, :count) }
  end

  context 'with year' do
    let(:items_count) { 1 }

    context 'reset period' do
      let(:holiday_expr) { create(:holiday_expr, expression: "2018/#{month}/#{day}") }

      it { expect(service.period_to_generate).to eq(2018..2018) }
    end

    context 'simple type' do
      let(:holiday_expr) { create(:holiday_expr, expression: "2018/#{month}/#{day}") }

      it { expect { service.call }.to change(Holiday, :count).by(items_count) }
      it do
        service.call
        expect(Holiday.first.date).to eq(holiday_expr.expression.to_date)
      end
    end

    context 'nth-day type' do
      let(:nth) { [-4, -3, -2, -1, 1, 2, 3, 4][rand(8)] }
      let(:day_of_week) { Faker::Number.between(1, 7) }
      let(:holiday_expr) { create(:holiday_expr, expression: "2018/#{month}/#{nth},#{day_of_week}") }

      it { expect { service.call }.to change(Holiday, :count).by(items_count) }

      context do
        before { service.call }

        it { expect(Holiday.first.date.cwday).to eq(day_of_week) }
        it { expect(Holiday.first.date.month).to eq(month) }
        it { expect(Holiday.first.date.month == (Holiday.first.date - nth.weeks).month).to be false }
      end
    end

    context 'period type' do
      let(:holiday_expr) { create(:holiday_expr, expression: "2018/#{month}/#{period_day_from}-#{period_day_to}") }

      it { expect { service.call }.to change(Holiday, :count).by(period_days.count) }

      context do
        before { service.call }

        it { expect(Holiday.all.all? { |h| h.date.month == month && h.date.day.in?(period_days) }).to be true }
      end
    end

    context 'large period type' do
      let(:holiday_expr) { create(:holiday_expr, expression: "2018/(#{period_month_from}/#{period_day_from})-(#{period_month_to}/#{period_day_to})") }
      let(:items_count) { (Date.civil(2018, period_month_from, period_day_from)..Date.civil(2018, period_month_to, period_day_to)).count }

      it { expect { service.call }.to change(Holiday, :count).by(items_count) }

      context do
        before { service.call }

        it { expect(Holiday.all.all? { |h| h.date.month.in?(period_months) }).to be true }
      end

      context 'on the verge of years' do
        let(:year) { Faker::Number.between(1970, 2038) }
        let(:holiday_expr) { create(:holiday_expr, expression: "#{year}/(12/31)-(01/01)") }
        let(:items_count) { 2 }

        it { expect { service.call }.to change(Holiday, :count).by(items_count) }

        it do
          service.call
          expect(Holiday.first.date.year).to eq year
          expect(Holiday.last.date.year).to eq year + 1
        end
      end
    end

    context 'full moon type' do
      let(:holiday_expr) { create(:holiday_expr, expression: "2018/#{month}/full-moon") }
      let!(:items_count) { FullMoonService.in(2018, month).count }

      it { expect { service.call }.to change(Holiday, :count).by(items_count) }
      it { expect(Holiday.all.all? { |h| h.date.in?(FullMoonService.in(h.date.year, h.date.month)) }) }
    end
  end

  context 'without year' do
    let(:items_count) { period.count }

    context 'simple type' do
      let(:holiday_expr) { create(:holiday_expr, expression: "#{month}/#{day}") }

      it { expect { service.call }.to change(Holiday, :count).by(items_count) }
      it do
        service.call
        expect(Holiday.all.all? { |h| h.date.month == month && h.date.day == day }).to be true
      end
    end

    context 'nth-day type' do
      let(:nth) { [-4, -3, -2, -1, 1, 2, 3, 4][rand(8)] }
      let(:day_of_week) { Faker::Number.between(1, 7) }
      let(:month) { Faker::Number.between(1, 12) }
      let(:holiday_expr) { create(:holiday_expr, expression: "#{month}/#{nth},#{day_of_week}") }

      it { expect { service.call }.to change(Holiday, :count).by(items_count) }

      context do
        before { service.call }

        it { expect(Holiday.all.all? { |h| h.date.cwday == day_of_week }).to be true }
        it { expect(Holiday.all.all? { |h| h.date.month == month }).to be true }
        it { expect(Holiday.all.all? { |h| h.date.month != (h.date - nth.weeks).month }).to be true }
      end
    end

    context 'period type' do
      let(:holiday_expr) { create(:holiday_expr, expression: "#{month}/#{period_day_from}-#{period_day_to}") }
      let!(:items_count) do
        period.map do |year|
          (Date.civil(year, month, period_day_from)..Date.civil(year, month, period_day_to)).count
        end.sum
      end
      it { expect { service.call }.to change(Holiday, :count).by(items_count) }

      context do
        before { service.call }

        it { expect(Holiday.all.all? { |h| h.date.month == month && h.date.day.in?(period_days) }).to be true }
      end
    end

    context 'large period type' do
      let(:holiday_expr) { create(:holiday_expr, expression: "(#{period_month_from}/#{period_day_from})-(#{period_month_to}/#{period_day_to})") }
      let!(:items_count) do
        period.map do |year|
          (Date.civil(year, period_month_from, period_day_from)..Date.civil(year, period_month_to, period_day_to)).count
        end.sum
      end

      it { expect { service.call }.to change(Holiday, :count).by(items_count) }

      context do
        before { service.call }

        it { expect(Holiday.all.all? { |h| h.date.month.in?(period_months) }).to be true }
      end
    end

    context 'full moon type' do
      let(:holiday_expr) { create(:holiday_expr, expression: "#{month}/full-moon") }
      let!(:items_count) { period.map { |year| FullMoonService.in(year, month).count }.sum }

      it { expect { service.call }.to change(Holiday, :count).by(items_count) }
      it { expect(Holiday.all.all? { |h| h.date.in?(FullMoonService.in(h.date.year, h.date.month)) }) }
    end
  end
end