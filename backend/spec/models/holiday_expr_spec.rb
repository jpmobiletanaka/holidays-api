require 'rails_helper'

describe HolidayExpr do
  subject(:model) { described_class.new(main_attrs) }

  let(:country) { create(:country) }
  let(:main_attrs) do
    {
      country_code: country.country_code,
      expression: '2020.2.8',
      ja_name: I18n.with_locale(:ja) { Faker::Name.name },
      en_name: Faker::Name.name,
      calendar_type: :gregorian }
  end

  it { expect { model.save }.to have_enqueued_job.on_queue('generate_holidays') }
  it 'saves model' do
    expect{ perform_enqueued_jobs { model.save }}.to change(described_class, :count).by(1)
  end

  it 'creates hotel' do
    expect{ perform_enqueued_jobs { model.save }}.to change(Holiday, :count).by(1)
  end



  describe 'update' do
    before { perform_enqueued_jobs { model.save }}

    let(:params) { { expression: '(2020.1.31)-(2020.2.2)', processed: false }}

    it 'updates model' do
      expect{ perform_enqueued_jobs { model.update(params) }}.not_to change(described_class, :count)
    end
  end

  context 'should be valid' do
    it { expect(model.valid?).to be true }
    it { model.expression = '2018/01/01';         expect(model.valid?).to be true }
    it { model.expression = '2018.01.01';         expect(model.valid?).to be true }
    it { model.expression = '2018.1.1';           expect(model.valid?).to be true }
    it { model.expression = '01/01';              expect(model.valid?).to be true }
    it { model.expression = '1/1';                expect(model.valid?).to be true }
    it { model.expression = '01.01';              expect(model.valid?).to be true }
    it { model.expression = '1.1';                expect(model.valid?).to be true }
    it { model.expression = '12.21';              expect(model.valid?).to be true }
    it { model.expression = '2018/12/21';         expect(model.valid?).to be true }
    it { model.expression = '2018.12.21';         expect(model.valid?).to be true }

    it { model.expression = '1/1,1';              expect(model.valid?).to be true }
    it { model.expression = '1.1,1';              expect(model.valid?).to be true }
    it { model.expression = '01.1,1';             expect(model.valid?).to be true }
    it { model.expression = '1/4,1';              expect(model.valid?).to be true }
    it { model.expression = '1/-4,1';             expect(model.valid?).to be true }
    it { model.expression = '12/-1,4';            expect(model.valid?).to be true }
    it { model.expression = '2018/12/-1,4';       expect(model.valid?).to be true }
    it { model.expression = '2018.12.-1,4';       expect(model.valid?).to be true }

    it { model.expression = '1/1-15';             expect(model.valid?).to be true }
    it { model.expression = '1.2-3';              expect(model.valid?).to be true }
    it { model.expression = '12.2-31';            expect(model.valid?).to be true }
    it { model.expression = '2018.12.2-31';       expect(model.valid?).to be true }
    it { model.expression = '2018/12/2-31';       expect(model.valid?).to be true }

    it { model.expression = '(11/2)-(12/4)';      expect(model.valid?).to be true }
    it { model.expression = '2018/(11/2)-(12/4)'; expect(model.valid?).to be true }
    it { model.expression = '2018/(12/31)-(1/6)'; expect(model.valid?).to be true }

    it { model.expression = '1/full-moon';        expect(model.valid?).to be true }
    it { model.expression = '1/full_moon';        expect(model.valid?).to be true }
    it { model.expression = '1/fullmoon';         expect(model.valid?).to be true }
    it { model.expression = '1.fullmoon';         expect(model.valid?).to be true }
    it { model.expression = '01.fullmoon';        expect(model.valid?).to be true }
    it { model.expression = '2018.01.fullmoon';   expect(model.valid?).to be true }
    it { model.expression = '2018/01/fullmoon';   expect(model.valid?).to be true }
    it { model.expression = '2018/01/full-moon';  expect(model.valid?).to be true }

    it { model.expression = '2020.1.31-2020.2.2';  expect(model.valid?).to be true }
    it { model.expression = '(2020.1.31)-(2020.2.2)';  expect(model.valid?).to be true }
  end

  context 'should be invalid' do
    it { model.country_code = :ru;                expect(model.valid?).to be false }
    it { model.expression = '0/1';                expect(model.valid?).to be false }
    it { model.expression = '0.1';                expect(model.valid?).to be false }
    it { model.expression = '100/12';             expect(model.valid?).to be false }
    it { model.expression = '100/35';             expect(model.valid?).to be false }
    it { model.expression = '10/35';              expect(model.valid?).to be false }
    it { model.expression = '10.35';              expect(model.valid?).to be false }
    it { model.expression = '101.10.35';          expect(model.valid?).to be false }
    it { model.expression = '1010/10/35';         expect(model.valid?).to be false }

    it { model.expression = '1/1,10';             expect(model.valid?).to be false }
    it { model.expression = '1.1,10';             expect(model.valid?).to be false }
    it { model.expression = '15.1,10';            expect(model.valid?).to be false }
    it { model.expression = '2018.15.-1,4';       expect(model.valid?).to be false }
    it { model.expression = '2018/01/-5,4';       expect(model.valid?).to be false }
    it { model.expression = '2018/01/5,4';        expect(model.valid?).to be false }
    it { model.expression = '2018/01/1,8';        expect(model.valid?).to be false }

    it { model.expression = '1/1-41';             expect(model.valid?).to be false }
    it { model.expression = '1.-1-45';            expect(model.valid?).to be false }
    it { model.expression = '15.2-31';            expect(model.valid?).to be false }
    it { model.expression = '2018.13.2-31';       expect(model.valid?).to be false }
    it { model.expression = '2018/13/2-31';       expect(model.valid?).to be false }

    it { model.expression = '13/full-moon';       expect(model.valid?).to be false }
    it { model.expression = '2/ful-moon';         expect(model.valid?).to be false }
    it { model.expression = '2018.2.fulmoon';     expect(model.valid?).to be false }
  end
end
