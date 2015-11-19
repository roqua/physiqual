module Physiqual
  describe Token do
    let(:user) { FactoryGirl.create(:physiqual_user) }
    it 'should not be possible to have a person with the same token type twice' do
      FactoryGirl.create(:physiqual_token, :google, physiqual_user: user)
      token2 = FactoryGirl.build(:physiqual_token, :google, physiqual_user: user)
      expect(token2.valid?).to be_falsey
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
        result = described_class.send(:provider_token, google, user)
        expect(result).to eq(google_token)
      end

      it 'returns the google token if google is the provider' do
        result = described_class.send(:provider_token, fitbit, user)
        expect(result).to eq(fitbit_token)
      end

      it 'raises an error if the provider is different' do
        expect do
          described_class.send(:provider_token, 'somethin-which-is-not-a-provider', user)
        end.to raise_error(Errors::ServiceProviderNotFoundError)
      end
    end
  end
end
