shared_examples_for 'a token' do
  before :each do
    subject.user = FactoryGirl.create(:user)
  end

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

  describe 'expired' do
    it 'should return true when a token is expired' do
      Timecop.freeze(Time.now)
      subject.valid_until = 10.days.ago
      subject.save!
      expect(subject.expired?).to be_truthy
      Timecop.return
    end

    it 'should return true when a token is blank' do
      subject.valid_until = nil
      subject.save!
      expect(subject.expired?).to be_truthy
    end

    it 'should return false when a token is still valid' do
      Timecop.freeze(Time.now)
      subject.valid_until = 1.hour.from_now
      subject.save!
      expect(subject.expired?).to be_falsey
      Timecop.return
    end
  end

  describe 'encodes' do
    it 'encodes the client id and secret seperated by a :' do
      result = subject.encode_key
      decoded = Base64.decode64(result)
      expected = "#{subject.class.client_id}:#{subject.class.client_secret}"
      expect(decoded).to eq(expected)
    end
  end

  describe 'complete' do
    it 'is false if the token is blank' do
      subject.token = nil
      subject.refresh_token = 'refresh_token'
      expect(subject.complete?).to be_falsey
    end

    it 'is false if the refresh_token is blank' do
      subject.refresh_token = nil
      subject.token = 'token'
      expect(subject.complete?).to be_falsey
    end

    it 'is true if both the token and refresh are set' do
      subject.refresh_token = 'refresh_token'
      subject.token = 'token'
      expect(subject.complete?).to be_truthy
    end
  end
end
