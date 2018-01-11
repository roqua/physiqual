require 'rails_helper'
module Physiqual
  module Sessions
    describe TokenAuthorizedSession do
      describe 'get' do
        let(:token) { FactoryBot.build(:google_token) }
        it 'should raise an error when there is a weird response' do
          error_msg = 'error'
          result = double('result')
          response = double('response')
          allow(result).to receive(:response).and_return(response)
          allow(response).to receive(:code).and_return('404')
          allow(response).to receive(:to_s).and_return(error_msg)
          allow(HTTParty).to receive(:get).and_return(result)
          expect { described_class.new(token).get('') }.to raise_error(Errors::UnexpectedHttpResponseError)
        end

        it 'should not raise an error with a 200 response' do
          response_hash = { 'all' => 'well' }
          response_json = '{"all" : "well"}'
          result = double('result')
          response = double('response')
          allow(result).to receive(:response).and_return(response)
          allow(response).to receive(:code).and_return('200')
          allow(result).to receive(:body).and_return(response_json)
          allow(HTTParty).to receive(:get).and_return(result)
          expect(described_class.new(token).get('')).to eq(response_hash)
        end
      end
    end
  end
end
