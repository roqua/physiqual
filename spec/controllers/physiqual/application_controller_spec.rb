require 'rails_helper'
module Physiqual
  describe ApplicationController do
    describe 'error renderings head 404' do
      it 'no_token_exists' do
        expect(subject).to receive(:render)
          .with(status: 404,
                plain: 'ERROR: No token of the specified service ' \
                                 'provider exists for the current user.'
               ) { fail(StandardError, 'stop_execution') }
        expect { subject.no_token_exists }.to raise_error('stop_execution')
      end

      it 'service_provider_not_found' do
        expect(subject).to receive(:render)
          .with(status: 404,
                plain: 'ERROR: The specified service provider does not exist ' \
                                            '(or no service provider was specified).'
               ) { fail(StandardError, 'stop_execution') }
        expect { subject.service_provider_not_found }.to raise_error('stop_execution')
      end

      it 'no_session_exists' do
        expect(subject).to receive(:render)
          .with(status: 404,
                plain: 'ERROR: Session token for user was not set (physiqual_user_id).'
               ) { fail(StandardError, 'stop_execution') }
        expect { subject.no_session_exists }.to raise_error('stop_execution')
      end

      it 'invalid_params' do
        exception = Exception.new('123')
        expect(subject).to receive(:render)
          .with(status: 404,
                plain: 'ERROR: The provided params are incorrect or not specified (123)'
               ) { fail(StandardError, 'stop_execution') }
        expect { subject.invalid_params(exception) }.to raise_error('stop_execution')
      end

      it 'unexpected_http_response' do
        exception = Exception.new('123')
        expect(subject).to receive(:render)
          .with(status: 404,
                plain: 'ERROR: Encountered an unexpected HTTP Response while retrieving data: (123)'
               ) { fail(StandardError, 'stop_execution') }
        expect { subject.unexpected_http_response(exception) }.to raise_error('stop_execution')
      end
    end
  end
end
