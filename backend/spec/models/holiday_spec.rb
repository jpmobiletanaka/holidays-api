require 'rails_helper'

RSpec.describe Holiday do
  subject(:model) { described_class.new(main_attrs) }

  let(:country) { create(:country) }
  let(:main_attrs) do
    { country_code: country.country_code, observed: false, ja_name: I18n.with_locale(:ja) { Faker::Name.name },
      en_name: Faker::Name.name, current_source_type: Holiday.current_source_types[:manual] }
  end

  describe 'when created' do
    it 'creates a new HolidayHistory record' do
      expect { model.save! }.to change(HolidayHistory, :count).by(1)
    end
  end

  context 'when updated' do
    it 'creates a new HolidayHistory record' do
      expect { model.save! }.to change(HolidayHistory, :count).by(1)
    end
  end
end
