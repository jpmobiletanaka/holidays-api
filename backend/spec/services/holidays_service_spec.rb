require 'rails_helper'

RSpec.describe Api::V1::HolidaysService do
  subject(:service) { described_class.new(params) }

  describe '#call' do
    let(:old_expr) { create(:holiday_expr, expression: '1.1', ja_name: I18n.with_locale(:ja) { "元旦" }, en_name: "New Year") }
    let(:another_old_expr) { create(:holiday_expr, expression: '5.4', ja_name: I18n.with_locale(:ja) { "みどりの日" }, en_name: "Greenery Day") }
    let(:new_expr) { create(:holiday_expr, expression: '5.5', ja_name: I18n.with_locale(:ja) { "子供の日" }, en_name: "Children's Day") }

    before do
      perform_enqueued_jobs do
        travel_to(Date.parse("2018-01-01")) { old_expr }
        travel_to(Date.parse("2017-05-04")) { another_old_expr }
        new_expr
      end
    end

    context 'when params[:date] is present' do
      let(:params) { { date: '2018-01-01' } }

      it 'returns records according to date' do
        expect(service.call.count).to eq(2)
      end
    end

    context 'when params[:date] is empty' do
      let(:params) { {} }

      it 'returns all holidays in year' do
        expect(service.call.count).to eq(3)
      end
    end
  end
end
