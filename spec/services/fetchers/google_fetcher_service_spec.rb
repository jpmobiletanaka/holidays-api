require 'rails_helper'

describe Fetchers::GoogleFetcherService do
  before do
    allow_any_instance_of(GoogleHolidayCalendar::Calendar).to receive(:holidays).and_return(holidays_hash)
  end

  let(:country) { create :country, google_calendar_id: 'fake_google_calendar_id', country_code: :ru }

  let(:holidays_hash) do
    {"2019-01-01"=>"New Year's Day",
     "2019-01-02"=>"New Year Holiday Week",
     "2019-01-03"=>"New Year Holiday Week",
     "2019-01-04"=>"New Year Holiday Week",
     "2019-01-07"=>"Orthodox Christmas Day",
     "2019-01-08"=>"New Year Holiday Week",
     "2019-02-23"=>"Defender of the Fatherland Day",
     "2019-03-08"=>"International Women's Day",
     "2019-05-01"=>"Spring and Labor Day",
     "2019-05-02"=>"Spring and Labor Day Holiday",
     "2019-05-03"=>"Spring and Labor Day Holiday",
     "2019-05-09"=>"Victory Day",
     "2019-05-10"=>"Defender of the Fatherland Day holiday",
     "2019-06-12"=>"Russia Day",
     "2019-09-01"=>"Day of Knowledge",
     "2019-11-04"=>"Unity Day"
    }.each_with_object({}) { |(date, event), res| res[Date.parse(date)] = event }
  end

  subject(:service_call) { described_class.call(langs: %i[en ja], country: country) }

  describe 'multiple languages' do
    before { service_call }
    it 'saves title for both languages' do
      expect(HolidayExpr.all.pluck(:en_name, :ja_name).flatten.all?).to be_truthy
    end
  end

  describe 'expression format' do
    context 'when result includes holidays with same name and multiple dates' do
      before { service_call }
      it 'creates single holiday with date range expression' do
        holiday_expr = HolidayExpr.where(en_name: "New Year Holiday Week")
        expect(holiday_expr.size).to eq 1
        expect(holiday_expr.first.expression).to eq('1.2-8')
      end
    end

    context 'when result includes single holiday for date' do
      before { service_call }
      it 'creates single holiday with date range' do
        holiday_expr = HolidayExpr.where(en_name: "Russia day")
        expect(holiday_expr.size).to eq 1
        expect(holiday_expr.first.expression).to eq('6.12')
      end
    end
  end

  describe 'holidays grouping' do
    context 'when result includes holidays with same name in one language, but different names in other language' do
      let(:en_holidays_hash) do
        {"2019-01-01"=>"New Year's Day",
         "2019-01-02"=>"New Year Holiday Week",
         "2019-01-03"=>"New Year Holiday Week",
         "2019-01-04"=>"New Year Holiday Week",
         "2019-01-07"=>"Orthodox Christmas Day",
         "2019-01-08"=>"New Year Holiday Week",
         "2019-02-23"=>"Defender of the Fatherland Day",
         "2019-03-08"=>"International Women's Day",
         "2019-05-01"=>"Spring and Labor Day",
         "2019-05-02"=>"Spring and Labor Day Holiday",
         "2019-05-03"=>"Spring and Labor Day Holiday",
         "2019-05-09"=>"Victory Day",
         "2019-05-10"=>"Defender of the Fatherland Day holiday",
         "2019-06-12"=>"Russia Day",
         "2019-09-01"=>"Day of Knowledge",
         "2019-11-04"=>"Unity Day"
        }.each_with_object({}) { |(date, event), res| res[Date.parse(date)] = event }
      end

      let(:ja_holidays_hash) do
        {"2019-01-01"=>"New Year's Day",
         "2019-01-02"=>"New Year Holiday Week",
         "2019-01-03"=>"New Year Holiday Week",
         "2019-01-04"=>"New Year Holiday Week2",
         "2019-01-07"=>"Orthodox Christmas Day",
         "2019-01-08"=>"New Year Holiday Week2",
         "2019-02-23"=>"Defender of the Fatherland Day",
         "2019-03-08"=>"International Women's Day",
         "2019-05-01"=>"Spring and Labor Day",
         "2019-05-02"=>"Spring and Labor Day Holiday",
         "2019-05-03"=>"Spring and Labor Day Holiday",
         "2019-05-09"=>"Victory Day",
         "2019-05-10"=>"Defender of the Fatherland Day holiday",
         "2019-06-12"=>"Russia Day",
         "2019-09-01"=>"Day of Knowledge",
         "2019-11-04"=>"Unity Day"
        }.each_with_object({}) { |(date, event), res| res[Date.parse(date)] = event }
      end

      before do
        args = { country: country.country_code, api_key: ENV['GOOGLE_CALENDAR_API_KEY'] }
        en_calendar = GoogleHolidayCalendar::Calendar.new(args.merge(lang: :en))
        ja_calendar = GoogleHolidayCalendar::Calendar.new(args.merge(lang: :ja))
        allow(GoogleHolidayCalendar::Calendar).to receive(:new).with(hash_including(lang: :en)).and_return(en_calendar)
        allow(GoogleHolidayCalendar::Calendar).to receive(:new).with(hash_including(lang: :ja)).and_return(ja_calendar)
        allow(en_calendar).to receive(:holidays).and_return(en_holidays_hash)
        allow(ja_calendar).to receive(:holidays).and_return(ja_holidays_hash)
        service_call
      end

      it 'creates single holiday with date range for each names group' do
        holiday_expr = HolidayExpr.where(ja_name: "New Year Holiday Week")
        holiday_expr2 = HolidayExpr.where(ja_name: "New Year Holiday Week2")
        expect(holiday_expr.size).to eq 1
        expect(holiday_expr.first.expression).to eq('1.2-3')
        expect(holiday_expr2.size).to eq 1
        expect(holiday_expr2.first.expression).to eq('1.4-8')
      end
    end
  end

  describe 'duplication check' do
    context 'when holiday with given expression already exists' do
      before do
        create :holiday_expr,
               en_name: "New Year's Day",
               ja_name: "New Year's Day",
               country_code: country.country_code,
               expression: '1.1',
               calendar_type: :gregorian
      end
      before { service_call }

      it "doesn't create duplicate" do
        expect(HolidayExpr.where(en_name: "New Year's Day").count).to eq 1
      end
    end
  end
end
