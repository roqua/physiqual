require 'rails_helper'
module Physiqual
  describe SessionsController do
    let(:user) { FactoryGirl.create(:physiqual_user) }
    let!(:base_url) { 'http://test.host' }
    # routes { Physiqual::Engine.routes }

    before :each do
      subject.session['physiqual_user_id'] = user.user_id
    end

    describe 'before filters' do
      it 'calls the find_token method when calling create' do
        expect(subject).to receive(:find_token) { fail(StandardError, 'stop_execution') }
        expect { post :create }.to raise_error('stop_execution')
      end
    end

    xdescribe 'failure' do
    end

    xdescribe 'destroy' do
    end

    describe 'authorize' do
      it 'heads 404 if no provider is given' do
        get :authorize
        expect(response.status).to eq(404)
      end

      it 'heads 404 if no user session is given' do
        subject.session['physiqual_user_id'] = nil
        get :authorize, provider: GoogleToken.csrf_token
        expect(response.status).to eq(404)
      end

      it 'creates a new user if it does not yet exist' do
        expect(subject).to receive(:user_session).and_return('non-existing-user-id')
        pre_count = User.count
        get :authorize, provider: FitbitToken.csrf_token
        expect(User.count).to eq pre_count + 1
      end

      describe 'with token usage' do
        before :each do
          expect(subject).to receive(:user_session).and_return(user.user_id)
        end

        it 'creates a new token if it does not yet exist' do
          pre_count = FitbitToken.count
          get :authorize, provider: FitbitToken.csrf_token
          expect(FitbitToken.count).to eq pre_count + 1
        end

        it 'creates a new token if it does not yet exist' do
          FactoryGirl.create(:fitbit_token, physiqual_user: user)

          pre_count = FitbitToken.count
          get :authorize, provider: FitbitToken.csrf_token
          expect(FitbitToken.count).to eq pre_count
        end
      end

      describe 'adds the correct return url token' do
        before :each do
          expect(subject).to receive(:user_session).and_return(user.user_id)
          session['physiqual_return_url'] = nil
          user.physiqual_tokens.destroy_all
        end

        it 'sets / if no return url is provided' do
          get :authorize, provider: GoogleToken.csrf_token
          expect(session['physiqual_return_url']).to_not be_nil
          expect(session['physiqual_return_url']).to eq '/'
        end

        it 'sets the return url if it is provided' do
          return_url = 'http://google.com'
          get :authorize, provider: GoogleToken.csrf_token, return_url: return_url
          expect(session['physiqual_return_url']).to_not be_nil
          expect(session['physiqual_return_url']).to eq return_url
        end
      end
    end

    describe 'redirects to the correct omniauth url for Google' do
      before :each do
        expect(subject).to receive(:user_session).and_return(user.user_id)
        user.physiqual_tokens.destroy_all
        get :authorize, provider: GoogleToken.csrf_token
      end

      it 'has the correct base url' do
        url = "#{base_url}/physiqual/auth/#{GoogleToken.csrf_token}"
        expect(response).to redirect_to(url)
      end
    end

    describe 'redirects to the correct omniauth url for Fitbit' do
      before :each do
        expect(subject).to receive(:user_session).and_return(user.user_id)
        user.physiqual_tokens.destroy_all
        get :authorize, provider: FitbitToken.csrf_token
      end

      it 'has the correct base url' do
        url = "#{base_url}/physiqual/auth/#{FitbitToken.csrf_token}"
        expect(response).to redirect_to(url)
      end
    end
  end
end
