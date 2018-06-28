require 'rails_helper'

RSpec.describe Auth::JwtService do
  subject { described_class }

  let(:payload) { HashWithIndifferentAccess.new(some_key: 'some_value') }
  let(:token) { 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzb21lX2tleSI6InNvbWVfdmFsdWUifQ.70-xcK9XKPbLBz_ykXV6DO9qfRFuBkFxXXBgHK3uLkg' }

  describe '#encode' do
    it { expect(subject.encode(payload)).to eq(token) }
  end

  describe '#decode' do
    it { expect(subject.decode(token)).to eq(payload) }
  end
end