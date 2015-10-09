module Physiqual
  describe Token do
    it 'should not be possible to have a person with the same token type twice' do
      user = FactoryGirl.create(:physiqual_user)
      FactoryGirl.create(:physiqual_token, :google, physiqual_user: user)
      token2 = FactoryGirl.build(:physiqual_token, :google, physiqual_user: user)
      expect(token2.valid?).to be_falsey
    end
  end
end
