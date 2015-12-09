module OmniAuth
  module Strategies
    class PhysiqualFitbitOauth2 < FitbitOauth2
      def name
        :physiqual_fitbit_oauth2
      end

      def path_prefix
        "#{Physiqual::Engine.routes.url_helpers.exports_path}[0..-8]}auth"
      end
    end

    class PhysiqualGoogleOauth2 < GoogleOauth2
      def name
        :physiqual_google_oauth2
      end

      def path_prefix
        "#{Physiqual::Engine.routes.url_helpers.exports_path}[0..-8]}auth"
      end
    end
  end
end
