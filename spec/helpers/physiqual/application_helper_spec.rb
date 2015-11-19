module Physiqual
  describe ApplicationHelper do
    describe "user_session" do
      it "should return the current user id if it exists" do
        user_session_id = '123'
        session['physiqual_user_id'] = user_session_id
        expect(helper.user_session).to eq user_session_id
      end

      it "should fail if the id is nil" do
        session['physiqual_user_id'] = nil
        expect { helper.user_session }.to raise_error Errors::NoSessionExistsError
      end
    end
  end
end