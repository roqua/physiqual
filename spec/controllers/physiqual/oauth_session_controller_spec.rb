require 'rails_helper'
# rubocop:disable Metrics/ModuleLength
module Physiqual
  describe OauthSessionController do
    let(:user) { FactoryGirl.create(:physiqual_user) }
    describe 'before filters' do
      it 'calls the check_token method when calling index' do
        expect(subject).to receive(:check_token) { fail(StandardError, 'stop_execution') }
        expect { get :index, email: user.email }.to raise_error('stop_execution')
      end

      it 'calls the set_token when calling authorize' do
        expect(subject).to receive(:set_token) { fail(StandardError, 'stop_execution') }
        expect { get :authorize }.to raise_error('stop_execution')
      end

      it 'calls the token when calling callback' do
        expect(subject).to receive(:token) { fail(StandardError, 'stop_execution') }
        expect { get :callback }.to raise_error('stop_execution')
      end
    end

    describe 'authorize' do
      it 'heads 404 if no provider is given' do
        get :authorize
        expect(response.status).to eq(404)
      end

      it 'redirects to the correct google url' do
        expect(subject).to receive(:current_user).and_return(user)
        get :authorize, provider: GoogleToken.csrf_token
        expect(response).to redirect_to('https://accounts.google.com/o/oauth2/auth?access_type=offline&approval_prompt=force&client_id=&redirect_uri=http%3A%2F%2Ftest.host%2Fphysiqual%2Foauth_session%2Fgoogle%2Fcallback&response_type=code&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Ffitness.activity.read+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Ffitness.body.read&state=google')
      end

      describe 'redirects to the correct google url' do
        before :each do
          expect(subject).to receive(:current_user).and_return(user)
          get :authorize, provider: GoogleToken.csrf_token
        end

        it 'has the correct base url' do
          expect(response).to redirect_to(/\A#{GoogleToken.oauth_site}#{GoogleToken.authorize_url}/)
        end

        it 'adds the correct redirect url' do
          url = CGI.escape subject.callback_oauth_session_index_url(provider: GoogleToken.csrf_token)
          expect(response).to redirect_to(/redirect_uri=#{url}/)
        end

        it 'adds the correct state' do
          expect(response).to redirect_to(/state=#{GoogleToken.csrf_token}/)
        end

        it 'adds the correct scope' do
          GoogleToken.scope.split(' ').each do |scope|
            expect(response).to redirect_to(/#{CGI.escape scope}/)
          end
        end
      end
      describe 'redirects to the correct fitbit url' do
        before :each do
          expect(subject).to receive(:current_user).and_return(user)
          get :authorize, provider: FitbitToken.csrf_token
        end

        it 'has the correct base url' do
          expect(response).to redirect_to(/\A#{FitbitToken.oauth_site}#{FitbitToken.authorize_url}/)
        end

        it 'adds the correct redirect url' do
          url = CGI.escape subject.callback_oauth_session_index_url(provider: FitbitToken.csrf_token)
          expect(response).to redirect_to(/redirect_uri=#{url}/)
        end

        it 'adds the correct state' do
          expect(response).to redirect_to(/state=#{FitbitToken.csrf_token}/)
        end

        it 'adds the correct scope' do
          FitbitToken.scope.split(' ').each do |scope|
            expect(response).to redirect_to(/#{scope}/)
          end
        end
      end
    end

    describe 'callback' do
    end

    describe 'current_user' do
    end

    describe 'check_token' do
      let(:provider) { GoogleToken.csrf_token }
      before :each do
        expect(subject).to receive(:current_user).and_return(user)
        subject.params[:state] = provider
      end

      after :each do
        subject.send(:check_token)
      end

      describe 'without tokens' do
        it 'redirects to the authorize path if the user does not have tokens' do
          expect(subject).to receive(:redirect_to).with(subject.authorize_oauth_session_index_path(provider: provider))
        end

        it 'redirects to the authorize path if the user only has incomplete token' do
          user.google_tokens.create
          user.google_tokens.each { |tok| expect(tok.complete?).to be_falsey }

          expect(subject).to receive(:redirect_to).with(subject.authorize_oauth_session_index_path(provider: provider))
        end
      end

      describe 'with tokens' do
        before :each do
          # If there is a token, the current user is called twice.
          expect(subject).to receive(:current_user).and_return(user)
        end

        after :each do
          user.google_tokens.each { |tok| expect(tok.complete?).to be_truthy }
        end

        it 'redirects to the authorize path if the user only has incomplete token' do
          token = FactoryGirl.build(:physiqual_token, :google, physiqual_user: user)
          user.physiqual_tokens << token
          user.save!
          user.google_tokens.each { |tok| expect(tok.expired?).to be_falsey }
        end

        it 'refreshes all expired tokens, also if one provider is called' do
          token = FactoryGirl.build(:physiqual_token, :google, valid_until: 10.minutes.ago, physiqual_user: user)
          token2 = FactoryGirl.build(:physiqual_token, :fitbit, valid_until: 10.minutes.ago, physiqual_user: user)
          user.physiqual_tokens << token
          user.physiqual_tokens << token2

          user.save!
          user.physiqual_tokens.each { |tok| expect(tok.expired?).to be_truthy }
          user.physiqual_tokens.each { |tok| expect(tok).to receive(:refresh!).and_return(true) }
        end
      end
    end

    describe 'set_token' do
      let(:provider) { GoogleToken.csrf_token }
      it 'heads 404 if there is no provider' do
        expect(subject).to receive(:head).with(404) { fail(StandardError, 'stop_execution') }
        expect { subject.send(:set_token) }.to raise_error('stop_execution')
      end

      it 'sets a new token if there are no tokens' do
        expect(subject).to receive(:current_user).and_return(user)
        subject.params[:provider] = provider
        subject.send(:set_token)
        expect(subject.instance_variable_get(:@token)).to_not be_nil
      end

      it 'sets an existing token, according to the provider provided ' do
        expect(subject).to receive(:current_user).and_return(user)
        token = FactoryGirl.build(:physiqual_token, :google, physiqual_user: user)
        user.physiqual_tokens << token
        user.save!

        subject.params[:provider] = provider
        subject.send(:set_token)
        expect(subject.instance_variable_get(:@token)).to_not be_nil
      end
    end

    describe 'token' do
      let(:provider) { GoogleToken.csrf_token }

      before :each do
        expect(subject).to receive(:current_user).and_return(user)
        subject.params[:provider] = provider
      end

      it 'should set the @ token variable with ' do
        token = FactoryGirl.create(:google_token, physiqual_user: user)
        subject.send(:token)
        expect(subject.instance_variable_get(:@token)).to eq(token)
      end

      it 'should head 404 if no tokens are present' do
        expect(subject).to receive(:head).with(404)
        subject.send(:token)
      end
    end

    describe 'provider_tokens' do
      let(:google) { GoogleToken.csrf_token }
      let(:fitbit) { FitbitToken.csrf_token }
      let(:google_token) { FactoryGirl.build(:google_token, physiqual_user: user) }
      let(:fitbit_token) { FactoryGirl.build(:fitbit_token, physiqual_user: user) }

      before :each do
        user.physiqual_tokens << google_token
        user.physiqual_tokens << fitbit_token
      end

      it 'returns the fitbit token if fitbit is the provider' do
        expect(subject).to receive(:current_user).and_return(user)
        result = subject.send(:provider_tokens, google)
        expect(result).to eq([google_token])
      end

      it 'returns the google token if google is the provider' do
        expect(subject).to receive(:current_user).and_return(user)
        result = subject.send(:provider_tokens, fitbit)
        expect(result).to eq([fitbit_token])
      end

      it 'returns nil if the provider is different' do
        expect(subject).to_not receive(:current_user)
        result = subject.send(:provider_tokens, 'somethin-which-is-not-a-token')
        expect(result).to eq(nil)
      end
    end

    describe 'get_or_create_token' do
      let(:google_token) { FactoryGirl.build(:google_token, physiqual_user: user) }
      let(:fitbit_token) { FactoryGirl.build(:fitbit_token, physiqual_user: user) }

      it 'returns the token if it exists' do
        result = subject.send(:get_or_create_token, [google_token])
        expect(result).to eq(google_token)
      end

      it 'creates a token with the correct class if it does not exist' do
        tokens = user.google_tokens
        result = subject.send(:get_or_create_token, tokens)
        expect(result).to be_a(Token)
        expect(result).to be_a(GoogleToken)

        tokens = user.fitbit_tokens
        result = subject.send(:get_or_create_token, tokens)
        expect(result).to be_a(Token)
        expect(result).to be_a(FitbitToken)
      end
    end

    describe 'sanitize_params' do
      it 'removes providers which are not correct' do
        fake_provider = 'fake-provider'
        subject.params[:provider] = fake_provider
        subject.send(:sanitize_params)
        expect(subject.params[:provider]).to be_nil
      end

      it 'leaves providers which are correct' do
        provider = GoogleToken.csrf_token
        subject.params[:provider] = provider
        subject.send(:sanitize_params)
        expect(subject.params[:provider]).to include(provider)
      end
    end
  end
end
# rubocop:enable Metrics/ModuleLength
