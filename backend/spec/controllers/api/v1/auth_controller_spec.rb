require 'rails_helper'

describe Api::V1::AuthController, type: :controller do
  let(:email) { Faker::Internet.email }
  let(:password) { Faker::Internet.password }
  let!(:user) { create(:user, email: email, password: password) }

  let(:params) { { email: email, password: password } }

  describe '#create' do
    it 'POST returns status: 200' do
      post :create, params: params
      expect(response.status).to eq(200)
    end

    it 'returns token' do
      post :create, params: params
      expect(JSON.parse(response.body)['token']).to eq(Auth::GenerateUserTokenCommand.call(email, password).result)
    end
  end
end
