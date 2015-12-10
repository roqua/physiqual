module Physiqual
  class ExportsController < Physiqual::ApplicationController
    include Physiqual::SessionsHelper, Physiqual::ExportsHelper

    before_filter :check_token, only: [:index, :raw]
    before_filter :assert_data_source, only: :raw
    before_filter :assert_service_provider, only: :raw
    before_filter :assert_first_measurement, only: [:raw, :index]
    before_filter :assert_number_of_days, only: [:raw, :index]

    rescue_from Errors::ServiceProviderNotFoundError, with: :service_provider_not_found
    rescue_from Errors::NoTokenExistsError, with: :no_token_exists
    rescue_from Errors::InvalidParamsError, with: :invalid_params
    rescue_from Errors::UnexpectedHttpResponseError, with: :unexpected_http_response

    def index
      respond_to do |format|
        format.html { @values = json_export }
        format.json { render json: json_export }
        format.csv { render text: csv_export }
      end
    end

    def raw
      render json: Exporters::RawExporter
        .new
        .configure(raw_params[:provider], raw_params[:data_source])
        .export(current_user.user_id, raw_params[:first_measurement], raw_params[:number_of_days])
    end

    private

    def json_export
      Exporters::JsonExporter.new.export(current_user.user_id,
                                         export_params[:first_measurement],
                                         export_params[:number_of_days])
    end

    def csv_export
      Exporters::CsvExporter.new.export(current_user.user_id,
                                        export_params[:first_measurement],
                                        export_params[:number_of_days])
    end

    def raw_params
      params.permit(:first_measurement, :number_of_days, :provider, :data_source)
    end

    def export_params
      params.permit(:first_measurement, :number_of_days, :format)
    end
  end
end
