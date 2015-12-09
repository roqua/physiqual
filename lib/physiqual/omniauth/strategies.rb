module OmniAuth::Strategies

  class PhysiqualFitbitOauth2 < FitbitOauth2
    def name
      :physiqual_fitbit_oauth2
    end
  end

  class PhysiqualGoogleOauth2 < GoogleOauth2
    def name
      :physiqual_google_oauth2
    end
  end

end
