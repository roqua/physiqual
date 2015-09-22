require 'shared_context_for_data_services'

module DataServices
  shared_examples_for 'a data_service' do |vcrs|
    it 'should define the extended methods funcion' do
      expect(subject.service_name).to_not eq DataService.new.service_name
    end
    it 'initializes without HTTParty, should be injected' do
      expect(described_class.ancestors).to_not include HTTParty
    end

    describe 'steps' do
      before { @result = run_with_vcr(vcrs, :steps) { subject.steps(from, to) } }

      it 'returns the steps in the correct format' do
        check_result_format(@result)
      end

      it 'gets the steps from the correct date till the correct date' do
        check_start_end_date(@result, from, to)
      end
    end

    describe 'heart_rate' do
      before { @result = run_with_vcr(vcrs, :heart_rate) { subject.heart_rate(from, to) } }

      it 'returns the heart_rate in the correct format' do
        check_result_format(@result)
      end

      it 'gets the heart_rate from the correct date till the correct date' do
        check_start_end_date(@result, from, to)
      end
    end

    describe 'sleep' do
      around(:each) do |test|
        @result = run_with_vcr(vcrs, :sleep) { subject.sleep(from, to) }
        @result == false ? test.skip : test.run
      end

      it 'returns the activities in the correct format' do
        check_result_format(@result)
      end

      it 'gets the activities from the correct date till the correct date' do
        check_start_end_date(@result, from, to)
      end
    end

    describe 'activities' do
      around(:each) do |test|
        @result = run_with_vcr(vcrs, :activities) { subject.activities(from, to) }
        @result == false ? test.skip : test.run
      end

      it 'returns the activities in the correct format' do
        check_result_format(@result)
      end

      it 'gets the activities from the correct date till the correct date' do
        check_start_end_date(@result, from, to)
      end
    end

    describe 'calories' do
      around(:each) do |test|
        @result = run_with_vcr(vcrs, :calories) { subject.calories(from, to) }
        @result == false ? test.skip : test.run
      end

      it 'returns the activities in the correct format' do
        check_result_format(@result)
      end

      it 'gets the activities from the correct date till the correct date' do
        check_start_end_date(@result, from, to)
      end
    end

    def run_with_vcr(vcrs, type)
      result = ''
      begin
        if vcrs
          VCR.use_cassette(vcrs[type]) do
            result = yield
          end
        else
          result = yield
        end
      rescue Errors::NotSupportedError
        result = false
      end
      result
    end
  end
end
