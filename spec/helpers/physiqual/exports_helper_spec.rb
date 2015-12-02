require 'rails_helper'
module Physiqual
  describe ExportsHelper do
    describe 'assert_service_provider' do
      it 'throws ServiceProviderNotFoundError if the provided provider is not allowed' do
        helper.params[:provider] = 'not-allowed-provider'
        expect { helper.assert_service_provider }.to raise_error Errors::ServiceProviderNotFoundError
      end

      it 'does not fail if it is allowed' do
        [GoogleToken.csrf_token, FitbitToken.csrf_token].each do |provider|
          helper.params[:provider] = provider
          helper.assert_service_provider
        end
      end
    end

    describe 'assert_data_source' do
      it 'throws InvalidParamsError if the provided data source is not allowed' do
        helper.params[:data_source] = 'not-allowed-provider'
        expect { helper.assert_data_source }.to raise_error Errors::InvalidParamsError, 'data source'
      end

      it 'does not fail if it is allowed' do
        %w(heart_rate calories steps activities sleep).each do |data_source|
          helper.params[:data_source] = data_source
          helper.assert_data_source
        end
      end
    end

    describe 'assert_first_measurement' do
      it 'throws InvalidParamsError if the provided first measurement is not provided' do
        helper.params[:first_measurement] = nil
        expect { helper.assert_first_measurement }.to raise_error Errors::InvalidParamsError,
                                                                  'first measurement missing'
      end

      it 'throws InvalidParamsError if the provided first measurement has an incorrect format' do
        helper.params[:first_measurement] = 'incorrectformat'
        expect { helper.assert_first_measurement }.to raise_error Errors::InvalidParamsError,
                                                                  'incorrect format of first measurement'
      end

      it 'does not fail if the first measurement is in the correct format' do
        helper.params[:first_measurement] = '2015-11-09 10:00'
        helper.assert_first_measurement
      end
    end

    describe 'assert_number_of_days' do
      it 'throws InvalidParamsError if the provided first measurement is not provided' do
        helper.params[:number_of_days] = nil
        expect { helper.assert_number_of_days }.to raise_error Errors::InvalidParamsError,
                                                               'number of days is missing'
      end

      it 'throws InvalidParamsError if the provided number of days is not allowed' do
        helper.params[:number_of_days] = 'not-allowed-provider'
        expect { helper.assert_number_of_days }.to raise_error Errors::InvalidParamsError,
                                                               'number of days not integer'
      end

      it 'does not fail if it is allowed' do
        helper.params[:number_of_days] = '30'
        helper.assert_number_of_days
      end
    end
  end
end
