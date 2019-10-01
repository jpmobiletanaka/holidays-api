require 'rails_helper'

describe Fetchers::S3FetcherService do
  let(:service) { described_class }
  let(:error_response) { }
  context 'when upload_id is nil' do
    it 'returns hash with state: :error' do
      expect { service.call(options: { upload_id: nil }) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'when upload_id not present' do
    it 'returns hash with state: :error' do
      expect { service.call(options: {}) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end


  context 'when upload id found' do
    let(:file) { File.new(file_fixture('ME_Holidays_data.csv')) }
    let!(:upload) do
      create :upload, file: file
    end

    context 'when all countries exist' do
      before do
        { cn: 'China', jp: 'Japan', tw: 'Taiwan'} .each do |code, name|
          Country.create! en_name: name, ja_name: name, country_code: code
        end
      end

      it 'creates creates holidays from file' do
        expect do
          expect do
            service.call(options: { upload_id: upload.id })
            upload.reload
          end.to change(upload, :status).from('pending').to('success')
        end.to change(HolidayExpr, :count).by(10)
      end

      describe 'expression' do
        before do
          service.call(options: { upload_id: upload.id })
        end

        it 'creates correct date range on year border' do
          expect(HolidayExpr.find_by(country_code: :tw, en_name: 'New Years Day'))
            .to have_attributes(expression: "2018.(12.31)-(1.1)")
        end

        it 'creates correct date range on month border' do
          service.call(options: { upload_id: upload.id })
          expect(HolidayExpr.find_by(country_code: :tw, en_name: 'Chinese New Year'))
            .to have_attributes(expression: "2017.(1.31)-(2.1)")
        end

        it 'creates correct date range' do
          expect(HolidayExpr.find_by(country_code: :cn, en_name: 'Spring Festival'))
            .to have_attributes(expression: "2015.2.18-20")
        end
      end

      describe 'grouping' do
        let(:csv) { CSV.parse(file.read, headers: true) }

        let(:events) do
          csv.map do |row|
            country = Country.find_by(en_name: row[csv.headers[4]])
            date_hash = %i(month day year).zip(row[csv.headers[1]].split('/')).to_h
            { country_code: country.country_code, calendar_type: :gregorian,
              date_hash: date_hash, en_name: [row[csv.headers[2]]].pack('a*'),
              ja_name: [row[csv.headers[3]]].pack('a*') }
          end.group_by { |row| [row[:country_code], row[:en_name]] }
        end

        it 'groups by country code and name before merge' do
          events.each do |_, row_group|
            expect(MergeEventGroupService).to receive(:call).with(events: row_group).ordered
          end
          service.call(options: { upload_id: upload.id })
        end
      end

      context 'when country is not found' do
        before { Country.find_by(en_name: 'Japan').destroy }
        let(:inst) { described_class.new(options: { upload_id: upload.id })}
        it 'adds such rows to invalid_rows instance var' do
          inst.call
          expect(inst.invalid_rows.size).to eq 8
        end
      end
    end
  end
end
