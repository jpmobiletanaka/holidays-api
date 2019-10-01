require 'rails_helper'

RSpec.describe Api::V1::HolidaysService do
  subject(:service) { described_class.new(params) }

  describe '#call' do
    let(:new_year) { create(:holiday_expr, expression: '2018/1.1', ja_name: I18n.with_locale(:ja) { "元旦" }, en_name: "New Year") }
    let(:holiday_week) { create(:holiday_expr, expression: '2018/1.1', en_name: new_year.en_name, ja_name: new_year.ja_name, country_code: new_year.country_code) }
    let(:greenery_day) { create(:holiday_expr, expression: '2017/5.4', ja_name: I18n.with_locale(:ja) { "みどりの日" }, en_name: "Greenery Day") }
    let(:children_day) { create(:holiday_expr, expression: '2019/5.5', ja_name: I18n.with_locale(:ja) { "子供の日" }, en_name: "Children's Day") }

    before do
      perform_enqueued_jobs do
        travel_to(Date.parse("2018-01-01")) { new_year }
        travel_to(Date.parse("2017-05-04")) { greenery_day }
        children_day
      end
    end

    context 'when params[:date] is present' do
      let(:params) { { date: '2018-01-30' } }

      it 'returns records according to date' do
        expect(service.call.count).to eq(2)
      end

      describe 'do not creates duplicates' do

        it 'raises an error' do
          expect{ holiday_week }.to raise_error(ActiveRecord::RecordNotUnique)
        end
      end
    end

    context 'when params[:date] is empty' do
      let(:params) { {} }

      it 'returns all holidays in year' do
        expect(service.call.count).to eq(1)
      end
    end
  end
end
