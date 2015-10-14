module Physiqual
  module Sessions
    class TokenAuthorizedSession < Session
      def initialize(token, base_uri)
        @base_uri = base_uri
        @header = { 'Authorization' => "Bearer #{token}" }
      end

      def get(path, params = {})
        send_get(full_url_for(path), params, @header)
      end

      private

      def full_url_for(path)
        @base_uri + path
      end
    end
  end
end
