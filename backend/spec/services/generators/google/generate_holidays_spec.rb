require 'rails_helper'

describe Generators::Google::GenerateHolidays do
  subject { described_class.call }

  let!(:country) { create :country }
  let!(:source_holiday_start) do
    create :google_raw_holiday, en_name: 'Christmas', ja_name: 'Christmas',
                                date: '2020-01-07', country_code: country.country_code
  end
  let!(:source_holiday_end) do
    create :google_raw_holiday, en_name: 'Christmas', ja_name: 'Christmas',
                                date: '2020-01-13', country_code: country.country_code
  end

  context 'when matching holidays in the same country overlapping source dates exist' do
    let(:dates_1) { Date.parse('2020-01-05')..Date.parse('2020-01-10') }
    let(:dates_2) { Date.parse('2020-01-11')..Date.parse('2020-01-15') }

    shared_examples_for :new_holidays_generated do
      let(:new_holiday) { Holiday.last }

      it 'destroys existing holidays' do
        expect(Holiday.where(id: old_ids)).to be_empty
      end

      it 'creates new holidays from raw holiday' do
        expect(new_holiday).to have_attributes(en_name: 'Christmas', ja_name: 'Christmas')
      end

      it 'creates new days from raw holiday' do
        expect(Day.where(holiday_id: new_holiday.id).count).to eq(new_days_count)
      end

      it "doesn't destroy old days" do
        expect(Day.where(holiday_id: old_ids).count).to eq(old_days_count)
      end
    end

    shared_examples_for :no_new_holidays do
      it "doesn't delete existing holidays" do
        expect {
          subject
        }.not_to change(Holiday, :count)
      end

      it "saves multiple holidays error to sources" do
        expect {
          subject
          source_holiday_start.reload
          source_holiday_end.reload
        }.to change { [source_holiday_start.error, source_holiday_end.error] }
          .from([nil, nil])
          .to([['Higher priority holidays found for this source'],
               ['Higher priority holidays found for this source']])
      end
    end

    context 'and multiple holidays overlap source dates' do
      let!(:holiday_1) { create :holiday, en_name: 'Christmas Day', country: country, dates: dates_1 }
      let!(:holiday_2) { create :holiday, en_name: 'Christmas Day 2', country: country, dates: dates_2 }
      let!(:old_days_count) { [*dates_1.to_a, *dates_2.to_a].size }
      let!(:new_days_count) { 7 }
      let!(:old_ids) { [holiday_1.id, holiday_2.id] }

      context 'and one of holidays has source priority higher than processed source' do
        before { holiday_1.update_column :source, Holiday.sources[:file] }
        before { holiday_2.update_column :source, Holiday.sources[:file] }

        include_examples :no_new_holidays
      end

      context 'and all holidays have source priority lower than processed source' do
        before { holiday_1.update_column :source, Holiday.sources[:google] + 1 }
        before { holiday_2.update_column :source, Holiday.sources[:google] + 1 }

        before { subject }

        include_examples :new_holidays_generated
      end

      context 'and all holidays have source priority equal to processed source' do
        before { holiday_1.update_column :source, Holiday.sources[:google] }
        before { holiday_2.update_column :source, Holiday.sources[:google] }

        before { subject }

        include_examples :new_holidays_generated
      end
    end

    context 'and one holiday overlap source dates' do
      let!(:holiday_1) { create :holiday, en_name: 'Christmas Day', country: country, dates: dates_1 }
      let!(:old_days_count) { dates_1.to_a.size }
      let!(:new_days_count) { 7 }
      let!(:old_ids) { [holiday_1.id] }

      context 'and existing holiday source priority is equal to processed source' do
        before do
          holiday_1.update_column :source, Holiday.sources[:google]
        end

        before { subject }

        include_examples :new_holidays_generated
      end

      context 'and existing holiday source priority is lower than processed source' do
        before { holiday_1.update_column :source, Holiday.sources[:google] + 1 }
        before { subject }

        include_examples :new_holidays_generated
      end

      context 'and existing source priority is higher than processed source' do
        before { holiday_1.update_column :source, Holiday.sources[:file] }

        include_examples :no_new_holidays
      end
    end
  end

  context 'when no holidays overlapping source dates exist' do
    let(:holiday) { Holiday.last }
    it 'creates new holiday' do
      expect { subject }.to change(Holiday, :count).by(1)
    end

    it 'creates new days' do
      expect { subject }.to change(Day, :count).by(7)
    end

    it 'sets sets source holiday id for created source' do
      expect {
        subject
        source_holiday_start.reload
        source_holiday_end.reload
      }.to change { [source_holiday_start.holiday_id, source_holiday_end.holiday_id] }
    end
  end
end
