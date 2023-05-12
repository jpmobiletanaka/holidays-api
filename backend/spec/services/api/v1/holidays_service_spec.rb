require 'rails_helper'

describe Api::V1::HolidaysService do
  subject(:service) { described_class.new(params) }
  let(:country) { create(:country, country_code: 'jp') }

  describe '#call' do
    let(:new_year) { create(:holiday_expr, country: country, expression: '2018/1.1', ja_name: I18n.with_locale(:ja) { "元旦" }, en_name: "New Year") }
    let(:holiday_week) { create(:holiday_expr, country: country, expression: '1.1-10', en_name: "Happy New Year") }
    let(:greenery_day) { create(:holiday_expr, country: country, expression: '2017/5.4', ja_name: I18n.with_locale(:ja) { "みどりの日" }, en_name: "Greenery Day") }
    let(:children_day) { create(:holiday_expr, country: country, expression: "2019/5.5", ja_name: I18n.with_locale(:ja) { "子供の日" }, en_name: "Children's Day") }
    let(:christmas_day) { create(:holiday_expr, country: country, expression: "#{Date.current.year}/1.7", ja_name: I18n.with_locale(:ja) { "子供の日" }, en_name: "Christmas Day") }

    before do
      perform_enqueued_jobs do
        travel_to(Date.parse("2018-01-01")) { new_year }
        travel_to(Date.parse("2017-05-04")) { greenery_day }
        children_day
        christmas_day
      end
    end

    context 'when params[:state_at] is present' do
      let(:params) { { state_at: '2018-01-30' } }

      context 'when params[:year] is not given' do
        it 'returns records according to date in year' do
          expect(service.call).to match([a_hash_including(en_name: new_year.en_name)])
        end
      end

      context 'when params[:year] is given' do
        before { params[:year] = '2017' }

        it 'returns records according to date in year' do
          expect(service.call).to match([
                                          a_hash_including(en_name: greenery_day.en_name),
                                          a_hash_including(en_name: new_year.en_name)
                                        ])
        end
      end

      context 'and new holiday created' do
        let(:params) { { state_at: Time.current + 1.day } }

        context 'when params[:year] is not given' do
          it 'returns new records with existing ones in year' do
            perform_enqueued_jobs { holiday_week }
            expect(service.call).to match([
                                            a_hash_including(en_name: holiday_week.en_name),
                                            a_hash_including(en_name: christmas_day.en_name)
                                          ])
          end
        end

        context 'when params[:year] is given' do
          before { params[:year] = '2019' }

          it 'returns new records with existing ones in year' do
            perform_enqueued_jobs { holiday_week }
            expect(service.call).to match([a_hash_including(en_name: holiday_week.en_name),
                                           a_hash_including(en_name: children_day.en_name)])
          end
        end
      end

      describe 'when holiday is deleted' do
        let!(:children_day) {
          create(:holiday_expr, country: country, expression: '2023/1.5', ja_name: I18n.with_locale(:ja) { "子供の日" }, en_name: "Children's Day")
        }
        let(:params) { { state_at: Time.current + 1.day } }

        it 'not includes only not deleted holiday' do
          perform_enqueued_jobs { holiday_week }
          holiday_id = HolidayExpr.find(holiday_week.id).holidays.first.id
          Holiday.find(holiday_id).delete

          expect(service.call).to match([
                                          a_hash_including(en_name: children_day.en_name),
                                          a_hash_including(en_name: christmas_day.en_name)
                                        ])
        end
      end
    end

    context 'when params[:state_at] is empty' do
      let(:params) { {} }
      let(:expected_attrs) do
        christmas_day.reload
                     .attributes
                     .slice(*described_class::HOLIDAY_ATTRS)
                     .except('id')
                     .symbolize_keys.merge(destroyed: false,
                                           recurring: false,
                                           current_source_type: 'manual',
                                           dates: ["#{Date.current.year}-1-7".to_date])
      end

      it 'returns all holidays in year' do
        expect(service.call.count).to eq(1)
      end

      it 'returns all fields within holiday' do
        expect(service.call.first).to include(expected_attrs.except(:created_at, :updated_at))
      end
    end
  end
end
