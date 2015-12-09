module OmniAuth
  module Strategies
    class PhysiqualFitbitOauth2 < FitbitOauth2
      def name
        :physiqual_fitbit_oauth2
      end

      def path_prefix
        '/physiqual/auth'
      end
    end

    class PhysiqualGoogleOauth2 < GoogleOauth2
      def name
        :physiqual_google_oauth2
      end

      def path_prefix
        '/physiqual/auth'
      end
    end
  end
end
