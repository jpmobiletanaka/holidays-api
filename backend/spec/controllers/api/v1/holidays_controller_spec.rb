require 'rails_helper'

describe Api::V1::HolidaysController, type: :controller do
  let(:email) { Faker::Internet.email }
  let(:password) { Faker::Internet.password }
  let!(:user) { create(:user, email: email, password: password) }
  let(:token) {  Auth::GenerateUserTokenCommand.call(email, password).result }

  let(:params) { {} }

  describe '#index' do
    context 'without token' do
      it 'GET returns status: Unauthorized' do
        post :index, params: params
        expect(response.status).to eq(401)
      end
    end

    context 'with token' do
      let(:token) { Auth::GenerateUserTokenCommand.call(email, password).result }

      it 'GET returns status: 200' do
        request.headers["Authorization"] = token
        post :index, params: params
        expect(response.status).to eq(200)
      end

      context 'with holidays' do
        let(:params) { { state_at: '2018-01-30' } }

        before do
          country = create(:country, country_code: 'jp')
          perform_enqueued_jobs do
            travel_to(Date.parse("2018-01-01")) do
              create(:holiday_expr, country: country, expression: '2018/1.1', ja_name: I18n.with_locale(:ja) { "元旦" }, en_name: "New Year")
            end
          end
        end

        it 'GET returns holidays' do
          request.headers["Authorization"] = token
          post :index, params: params
          expect(JSON.parse(response.body).first['en_name']).to eq("New Year")
        end
      end
    end
  end
end
