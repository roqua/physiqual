module Physiqual
  describe Token do
    let(:user) { FactoryGirl.create(:physiqual_user) }
    it 'should not be possible to have a person with the same token type twice' do
      FactoryGirl.create(:physiqual_token, :google, physiqual_user: user)
      token2 = FactoryGirl.build(:physiqual_token, :google, physiqual_user: user)
      expect(token2.valid?).to be_falsey
    end

    describe 'find_provider_token' do
      let(:google) { GoogleToken.csrf_token }
      let(:fitbit) { FitbitToken.csrf_token }
      let(:google_token) { FactoryGirl.create(:google_token, physiqual_user: user) }
      let(:fitbit_token) { FactoryGirl.create(:fitbit_token, physiqual_user: user) }

      it 'returns the fitbit token if fitbit is the provider' do
        fitbit_token
        result = described_class.send(:find_provider_token, fitbit, user)
        expect(result).to eq(fitbit_token)
      end

      it 'returns the google token if google is the provider' do
        google_token
        result = described_class.send(:find_provider_token, google, user)
        expect(result).to eq(google_token)
      end

      it 'returns nil if there is a fitbit token but google is the provider' do
        fitbit_token
        result = described_class.send(:find_provider_token, google, user)
        expect(result).to be_nil
      end

      it 'returns nil if there is a google token but fitbit is the provider' do
        google_token
        result = described_class.send(:find_provider_token, fitbit, user)
        expect(result).to be_nil
      end

      it 'raises an error if the provider is different' do
        fitbit_token
        expect do
          described_class.send(:find_provider_token, 'somethin-which-is-not-a-provider', user)
        end.to raise_error(Errors::ServiceProviderNotFoundError)
      end
    end
  end
end
