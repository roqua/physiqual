module Physiqual
  module Sessions
    class TokenAuthorizedSession
      def initialize(token)
        token.refresh! if token.expired?

        @base_uri = token.class.base_uri
        @header = { 'Authorization' => "Bearer #{token.token}" }
      end

      def get(path, params = {})
        result = HTTParty.get(full_url_for(path),
                              query: params,
                              headers: @header)
        Rails.logger.info result.to_yaml
        JSON.parse(result.body)
      end

      private

      def full_url_for(path)
        @base_uri + path
      end
    end
  end
end
