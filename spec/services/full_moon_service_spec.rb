require 'rails_helper'

RSpec.describe FullMoonService do
  subject(:service) { described_class }

  let(:year) { Faker::Number.between(1970, 2038) }
  let(:month) { Faker::Number.between(1, 12) }

  describe '#in' do
    context 'without month' do
      it { expect(service.in(year)).to be_a Hash }
      it { expect(service.in(year).keys.sort == (1..12).to_a).to be true }
      it { expect(service.in(year).values.all? { |v| v.is_a? Array }).to be true }
      it { expect(service.in(year).values.all? { |v| v.count.positive? }).to be true }
      it { expect(service.in(year).values.flatten.all? { |v| v.in? 1..31 }).to be true }
      it do
        expect do
          service.in(year).map { |month, days| days.map { |day| Date.civil(year, month, day) } }
        end.not_to raise_error
      end
    end

    context 'with month' do
      it { expect(service.in(year, month)).to be_an Array }
      it { expect(service.in(year, month).count).to be_positive }
      it { expect(service.in(year, month).all? { |v| v.in? 1..31 }).to be true }
      it { expect { service.in(year, month).map { |day| Date.civil(year, month, day) } }.not_to raise_error }
    end
  end
end