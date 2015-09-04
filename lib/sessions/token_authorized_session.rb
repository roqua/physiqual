module Sessions
  class TokenAuthorizedSession
    def initialize(token, base_uri)
      @base_uri = base_uri
      @header = { 'Authorization' => "Bearer #{token}" }
    end

    def get(path, params = {})
      result = HTTParty.get(full_url_for(path),
                            query: params,
                            headers: @header)

      JSON.parse(result.body)
    end

    private

    def full_url_for(path)
      @base_uri + path
    end
  end
end
