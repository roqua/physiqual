shared_examples_for 'a token' do
  it 'should define a base uri' do
    expect(described_class.base_uri).to_not be_blank
  end

  it 'should define a csrf_token' do
    expect(described_class.csrf_token).to_not be_blank
  end

  it 'should define a oauth site ' do
    expect(described_class.oauth_site).to_not be_blank
  end

  it 'should define a authorize url' do
    expect(described_class.authorize_url).to_not be_blank
  end

  it 'should define a token url' do
    expect(described_class.token_url).to_not be_blank
  end

  it 'should define a scope' do
    expect(described_class.scope).to_not be_blank
  end

  describe 'expired function' do
    it 'should return false when a token is expired' do
      token = FactoryGirl.create(:fitbit_token)
      Timcop.freeze(Time.now)
      token.valid_until = 10.days.ago
      token.save!
      expect(token.expired?).to be_truthy
      Timecop.return
    end
  end
end
