require 'rails_helper'
module Physiqual
  describe ExportsController do
    let!(:user) { FactoryBot.create(:physiqual_user) }
    let!(:google_token) { FactoryBot.create(:google_token, physiqual_user: user) }
    let!(:params) do
      { first_measurement: '2015-06-14 10:00', number_of_days: '39',
        provider: GoogleToken.csrf_token, data_source: 'heart_rate' }
    end

    before :each do
      subject.session['physiqual_user_id'] = user.user_id
      subject.params = params
      @routes = Engine.routes
    end

    describe 'before filters' do
      describe 'check_token' do
        before :each do
          expect(subject).to receive(:check_token) { raise(StandardError, 'stop_execution') }
        end
        it 'calls the check_token method when calling index' do
          expect { get :index, params }.to raise_error('stop_execution')
        end

        it 'calls the check_token method when calling raw' do
          expect { get :raw, params }.to raise_error('stop_execution')
        end
      end

      it 'calls the assert_data_source method when calling index' do
        expect(subject).to receive(:assert_data_source) { raise(StandardError, 'stop_execution') }
        expect { get :raw, params }.to raise_error('stop_execution')
      end

      it 'calls the assert_service_provider method when calling index' do
        expect(subject).to receive(:assert_service_provider) { raise(StandardError, 'stop_execution') }
        expect { get :raw, params }.to raise_error('stop_execution')
      end

      describe 'assert_first_measurement' do
        before { expect(subject).to receive(:assert_first_measurement) { raise(StandardError, 'stop_execution') } }
        it 'calls the assert_first_measurement method when calling index' do
          expect { get :index, params }.to raise_error('stop_execution')
        end
        it 'calls the assert_first_measurement method when calling raw' do
          expect { get :raw, params }.to raise_error('stop_execution')
        end
      end

      describe 'assert_number_of_days' do
        before { expect(subject).to receive(:assert_number_of_days) { raise(StandardError, 'stop_execution') } }
        it 'calls the assert_number_of_days method when calling index' do
          expect { get :index, params }.to raise_error('stop_execution')
        end

        it 'calls the assert_number_of_days method when calling raw' do
          expect { get :raw, params }.to raise_error('stop_execution')
        end
      end
    end

    describe 'index' do
      it 'responds to html format' do
        params[:format] = 'html'
        exporter = Exporters::JsonExporter.new
        expect(Exporters::JsonExporter).to receive(:new).and_return(exporter)
        expect(exporter).to receive(:export).and_return([])

        get :index, params
        expect(response.status).to eq 200
      end

      it 'responds to json format' do
        params[:format] = 'json'
        exporter = Exporters::JsonExporter.new
        expect(Exporters::JsonExporter).to receive(:new).and_return(exporter)
        expect(exporter).to receive(:export).and_return([])

        get :index, params
        expect(response.status).to eq 200
      end

      it 'responds to csv format' do
        params[:format] = 'csv'
        exporter = Exporters::CsvExporter.new
        expect(Exporters::CsvExporter).to receive(:new).and_return(exporter)
        expect(exporter).to receive(:export).and_return([])

        get :index, params
        expect(response.status).to eq 200
      end
    end

    describe 'raw' do
      it 'Calls the raw exporter with the correct params' do
        exporter = Exporters::RawExporter.new

        expect(Exporters::RawExporter).to receive(:new).and_return(exporter)
        expect(exporter).to receive(:export).and_return('x' => 'y')
        get :raw, params

        expect(response.body).to eq '{"x":"y"}'
        expect(response.status).to eq 200
      end
    end

    describe 'raw_params' do
      it 'removes everything but :first_measurement, :number_of_days, :provider, :data_source' do
        subject.params['x'] = '1'
        expect(subject.send(:raw_params).keys).to_not include('x')
        expect(subject.send(:raw_params).keys.size).to eq(4)
        expect(subject.send(:raw_params).keys).to include('first_measurement')
        expect(subject.send(:raw_params).keys).to include('number_of_days')
        expect(subject.send(:raw_params).keys).to include('provider')
        expect(subject.send(:raw_params).keys).to include('data_source')
      end
    end

    describe 'export_params' do
      it 'removes everything but first measurement and number of days' do
        subject.params['x'] = '1'
        expect(subject.send(:export_params).keys).to_not include('x')
        expect(subject.send(:export_params).keys.size).to eq(2)
        expect(subject.send(:export_params).keys).to include('first_measurement')
        expect(subject.send(:export_params).keys).to include('number_of_days')
      end
    end
  end
end
