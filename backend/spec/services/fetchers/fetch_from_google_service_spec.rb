require 'rails_helper'

describe Fetchers::FetchFromGoogleService do
  before do
    allow_any_instance_of(GoogleHolidayCalendar::Calendar).to receive(:holidays).and_return(holidays_hash)
  end

  let(:country) { create :country, google_calendar_id: 'fake_google_calendar_id', country_code: :ru }

  let(:holidays_hash) do
    {
      "2019-01-01" => "New Year's Day",
      "2019-01-02" => "New Year Holiday Week",
      "2019-01-03" => "New Year Holiday Week",
      "2019-01-04" => "New Year Holiday Week",
      "2019-01-07" => "Orthodox Christmas Day",
      "2019-01-08" => "New Year Holiday Week",
      "2019-02-23" => "Defender of the Fatherland Day",
      "2019-03-08" => "International Women's Day",
      "2019-05-01" => "Spring and Labor Day",
      "2019-05-02" => "Spring and Labor Day Holiday",
      "2019-05-03" => "Spring and Labor Day Holiday",
      "2019-05-09" => "Victory Day",
      "2019-05-10" => "Defender of the Fatherland Day holiday",
      "2019-06-12" => "Russia Day",
      "2019-09-01" => "Day of Knowledge",
      "2019-11-04" => "Unity Day"
    }.each_with_object({}) { |(date, event), res| res[Date.parse(date)] = event }
  end

  subject(:service_call) { described_class.call(langs: %i[en ja], options: { country: country }) }

  it 'saves raw holidays with pending state' do
    service_call
    expect(GoogleRawHoliday.all.pluck(:state).uniq).to eq(['pending'])
  end

  describe 'multiple languages' do
    let(:names) { holidays_hash.values.zip(holidays_hash.values) }
    before { service_call }

    it 'saves title for both languages' do
      expect(GoogleRawHoliday.all.pluck(:en_name, :ja_name)).to match_array(names)
    end
  end

  context 'when en name contains "observed" word' do
    before { holidays_hash["2019-01-04".to_date] = "New Year Holiday Week (observed)" }
    before { service_call }

    it 'saves holiday with observed = true' do
      expect(GoogleRawHoliday.find_by(date: '2019-01-04').observed).to be_truthy
    end
  end

  describe 'duplication check' do
    context 'when raw holiday already exists' do
      before do
        create :google_raw_holiday,
               en_name: "New Year's Day",
               ja_name: "New Year's Day",
               country_code: country.country_code,
               date: "2019-01-01".to_date
      end
      before { service_call }

      it "doesn't create duplicate" do
        expect(GoogleRawHoliday.where(en_name: "New Year's Day").count).to eq 1
      end
    end
  end
end
