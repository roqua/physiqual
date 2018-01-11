require 'rails_helper'

module Physiqual
  describe Users do
    let(:instance) { described_class.new }

    describe '#export' do
      let!(:user) { FactoryBot.create(:physiqual_user) }
      let!(:user2) { FactoryBot.create(:physiqual_user, :second) }
      let!(:google_token) { FactoryBot.create(:google_token, physiqual_user: user) }
      let!(:fitbit_token) { FactoryBot.create(:fitbit_token, physiqual_user: user2) }

      it 'returns the expected result' do
        expect(instance.send(:export)).to \
          eq("\"user_id\";\"service_provider\"\n\"user_id123\";\"Google Fit\"\n\"user_id456\";\"Fitbit\"\n")
      end
    end

    describe '#export_lines' do
      let!(:user) { FactoryBot.create(:physiqual_user) }
      let!(:google_token) { FactoryBot.create(:google_token, physiqual_user: user) }

      it 'yields control the correct amount of times for one user' do
        expect { |b| instance.send(:export_lines, &b) }.to yield_control.exactly(2).times
      end

      it 'yields control the correct amount of times for two users' do
        user2 = FactoryBot.create(:physiqual_user, :second)
        FactoryBot.create(:fitbit_token, physiqual_user: user2)
        expect { |b| instance.send(:export_lines, &b) }.to yield_control.exactly(3).times
      end
    end

    describe '#format_headers' do
      let(:headers) { %w[header_one header_two] }

      it 'works with one header' do
        my_headers = %w[profile_id]
        result = instance.send(:format_headers, my_headers)
        expect(result).to eq '"profile_id"'
      end

      it 'works with two headers' do
        result = instance.send(:format_headers, headers)
        expect(result).to eq '"header_one";"header_two"'
      end

      it 'returns an empty string when there are no headers' do
        result = instance.send(:format_headers, [])
        expect(result).to eq ''
      end
    end

    describe '#format_hash' do
      let(:headers) { %w[completed_at updated_at profile_id] }
      let(:date_string) { '01-01-2001' }
      let(:date2_string) { '01-02-2001' }
      let(:profile_id) { 'aaaa-aaab' }

      it 'works with a full row' do
        hsh = { 'profile_id' => profile_id,
                'updated_at' => date2_string,
                'completed_at' => date_string }
        result = instance.send(:format_hash, headers, hsh)
        expect(result).to eq "\"#{date_string}\";\"#{date2_string}\";\"#{profile_id}\""
      end

      it 'works when one value is missing' do
        hsh = { 'completed_at' => date_string,
                'profile_id' => profile_id }
        result = instance.send(:format_hash, headers, hsh)
        expect(result).to eq "\"#{date_string}\";;\"#{profile_id}\""
      end

      it 'works when the first value in a row is missing' do
        hsh = { 'updated_at' => date2_string,
                'profile_id' => profile_id }
        result = instance.send(:format_hash, headers, hsh)
        expect(result).to eq ";\"#{date2_string}\";\"#{profile_id}\""
      end

      it 'works when there is only one value in a row' do
        hsh = { 'profile_id' => profile_id }
        result = instance.send(:format_hash, headers, hsh)
        expect(result).to eq ";;\"#{profile_id}\""
      end

      it 'works when there are no values in the row' do
        hsh = {}
        result = instance.send(:format_hash, headers, hsh)
        expect(result).to eq ';;'
      end
    end
  end
end
