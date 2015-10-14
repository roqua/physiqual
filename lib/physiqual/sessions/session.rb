module Physiqual
  module Sessions
    class Session
      def send_get(path, params = {}, header = {})
        Rails.logger.debug "Calling #{@header}"
        result = HTTParty.get(full_url_for(path),
                              query: params,
                              headers: header)
        Rails.logger.info result.inspect
        Rails.logger.info result.headers.inspect
        JSON.parse(result.body)
      end
    end
  end
end
