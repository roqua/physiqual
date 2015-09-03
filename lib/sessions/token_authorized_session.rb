module Sessions
  class TokenAuthorizedSession
    def initialize(token)
      @token = token
      @header = { 'Authorization' => "Bearer #{@token.token}" }
    end

    def get(path, params = {})
      result = HTTParty.get(full_url_for(path),
                   query: params,
                  headers: @header)

      JSON.parse(result.body)
    end

    private

    def full_url_for(path)
      @token.class.base_uri + path
    end
  end
end
