require 'rails_helper'

RSpec.describe Auth::JwtService do
  subject { described_class }

  context 'not expirable token' do
    let(:payload) { HashWithIndifferentAccess.new(some_key: 'some_value') }
    let(:token) { 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzb21lX2tleSI6InNvbWVfdmFsdWUifQ.70-xcK9XKPbLBz_ykXV6DO9qfRFuBkFxXXBgHK3uLkg' }

    describe '#encode' do
      it 'returns tokenized payload' do
        expect(subject.encode(payload)).to eq(token)
      end
    end

    describe '#decode' do
      it 'returns decoded payload' do
        expect(subject.decode(token)).to eq(payload)
      end
    end
  end

  context 'expirable token' do
    let(:expires_at) { (Time.current + Faker::Number.number(1).to_i.hours).to_i }
    let(:payload) { HashWithIndifferentAccess.new(some_key: 'some_value', exp: expires_at) }

    describe '#decode' do
      it 'returns payload because of not expired token' do
        generated_token = subject.encode(payload)
        Timecop.freeze(Time.zone.at(expires_at - 1)) do
          expect(subject.decode(generated_token)).to eq payload
        end
      end

      it 'returns nil because of expired token' do
        generated_token = subject.encode(payload)
        Timecop.freeze(Time.zone.at(expires_at)) do
          expect(subject.decode(generated_token)).to be nil
        end
      end
    end
  end
end