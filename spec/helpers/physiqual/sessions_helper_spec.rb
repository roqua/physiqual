require 'rails_helper'
module Physiqual
  describe SessionsHelper do
    let(:user) { FactoryBot.create(:physiqual_user) }
    before :each do
      session['physiqual_user_id'] = user.user_id
    end

    describe 'current_user' do
      it 'returns the current user object' do
        my_user = helper.current_user
        expect(my_user).to_not be_nil
        expect(my_user).to eq user
      end

      it 'fails if the user is not found' do
        session['physiqual_user_id'] = nil
        expect { helper.current_user }.to raise_error Errors::NoSessionExistsError
      end
    end

    describe 'check_token' do
      before :each do
        expect(helper).to receive(:current_user).and_return(user)
      end

      describe 'without correct tokens' do
        it 'redirects to the authorize path if the user does not have tokens' do
          user.physiqual_token.destroy if user.physiqual_token
          expect { helper.check_token }.to raise_error Errors::NoTokenExistsError
        end

        it 'redirects to the authorize path if the user only has incomplete token' do
          user.create_physiqual_token(type: Physiqual::GoogleToken.to_s)
          expect(user.physiqual_token.complete?).to be_falsey
          expect { helper.check_token }.to raise_error Errors::NoTokenExistsError
        end
      end

      describe 'with tokens' do
        before :each do
          FactoryBot.create(:google_token, physiqual_user: user)
          expect(user.physiqual_token).to be_truthy
        end

        it 'does not fail' do
          helper.check_token
        end
      end
    end

    describe 'find_token' do
      let(:provider) { GoogleToken.csrf_token }

      before { expect(helper).to receive(:current_user).and_return(user) }

      it 'raise an error if there is no provider' do
        user.create_physiqual_token(type: Physiqual::GoogleToken.to_s)
        expect { helper.find_token }.to raise_error(Errors::ServiceProviderNotFoundError)
      end

      it 'sets a token if there is a token' do
        tok = FactoryBot.create(:google_token, physiqual_user: user)
        helper.params[:provider] = provider
        helper.find_token
        expect(helper.instance_variable_get(:@token)).to_not be_nil
        expect(helper.instance_variable_get(:@token)).to eq tok
      end

      it 'sets an existing token, according to the provider provided ' do
        FactoryBot.create(:fitbit_token, physiqual_user: user)
        helper.params[:provider] = FitbitToken.csrf_token
        helper.find_token
        expect(helper.instance_variable_get(:@token)).to_not be_nil
        expect(helper.instance_variable_get(:@token).type).to eq Physiqual::FitbitToken.to_s
      end
    end
  end
end
