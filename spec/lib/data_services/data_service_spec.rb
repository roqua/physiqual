require 'rails_helper'
require 'shared_context_for_data_services'
module DataServices
  describe DataService do
    include_context 'data_service context'
    describe 'methods should raise errors' do
      it 'should raise on steps' do
        expect { subject.steps(from, to) }.to raise_error 'Subclass does not implement steps method.'
      end

      it 'should raise on heart_rate' do
        expect { subject.heart_rate(from, to) }.to raise_error 'Subclass does not implement heart_rate method.'
      end

      it 'should raise on sleep' do
        expect { subject.sleep(from, to) }.to raise_error 'Subclass does not implement sleep method.'
      end

      it 'should raise on calories' do
        expect { subject.calories(from, to) }.to raise_error 'Subclass does not implement calories method.'
      end

      it 'should raise on activities' do
        expect { subject.activities(from, to) }.to raise_error 'Subclass does not implement activities method.'
      end
    end

    it 'should define a date_time_field' do
      expect(described_class::DATE_TIME_FIELD).to_not be_blank
      expect(subject.date_time_field).to_not be_blank
      expect(subject.date_time_field).to eq described_class::DATE_TIME_FIELD
    end

    it 'should define a values_field' do
      expect(described_class::VALUES_FIELD).to_not be_blank
      expect(subject.values_field).to_not be_blank
      expect(subject.values_field).to eq described_class::VALUES_FIELD
    end

    it 'should have a different values and date_time field' do
      expect(described_class::DATE_TIME_FIELD).to_not eq described_class::VALUES_FIELD
    end

    describe 'output_entry' do
      let(:date) { Time.now }

      it 'should be able to generate an output entry' do
        values = [123]
        result = subject.output_entry(date, values)
        expect(result).to be_a Hash
        expect(result[subject.date_time_field]).to eq date
        expect(result[subject.values_field]).to eq values
      end

      it 'should be able to create an array from a list of values if it is not yet a list' do
        values = 123
        result = subject.output_entry(date, values)
        expect(result[subject.values_field]).to eq [values]
      end

      it 'should flatten nested arrays' do
        values = [[[123]]]
        result = subject.output_entry(date, values)
        expect(result[subject.values_field]).to eq values.flatten
      end
    end
  end
end
