# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiService do
  describe '#retrieve_data' do
    subject(:service) { described_class.new(params: params) }

    describe 'COVID-19 data endpoints' do
      context 'when fetching all world data' do
        let(:params) { 'all' }
        let(:response_body) do
          {
            'updated' => 1_640_000_000_000,
            'cases' => 300_000_000,
            'deaths' => 5_000_000
          }.to_json
        end

        before do
          stub_request(:get, "#{ENV.fetch('DISEASES_API', 'https://disease.sh/v3/covid-19/')}all")
            .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
        end

        it 'returns parsed JSON data' do
          result = service.retrieve_data

          expect(result).to be_a(Hash)
          expect(result['cases']).to eq(300_000_000)
        end
      end

      context 'when fetching countries data' do
        let(:params) { 'countries' }
        let(:response_body) do
          [
            { 'country' => 'USA', 'cases' => 50_000_000 },
            { 'country' => 'India', 'cases' => 35_000_000 }
          ].to_json
        end

        before do
          stub_request(:get, "#{ENV.fetch('DISEASES_API', 'https://disease.sh/v3/covid-19/')}countries")
            .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
        end

        it 'returns array of countries' do
          result = service.retrieve_data

          expect(result).to be_an(Array)
          expect(result.length).to eq(2)
        end
      end

      context 'when fetching continents data' do
        let(:params) { 'continents' }
        let(:response_body) do
          [
            { 'continent' => 'Asia', 'population' => 4_000_000_000 },
            { 'continent' => 'Europe', 'population' => 750_000_000 }
          ].to_json
        end

        before do
          stub_request(:get, "#{ENV.fetch('DISEASES_API', 'https://disease.sh/v3/covid-19/')}continents")
            .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
        end

        it 'returns array of continents' do
          result = service.retrieve_data

          expect(result).to be_an(Array)
          expect(result.first['continent']).to eq('Asia')
        end
      end
    end

    describe 'vaccination data endpoint' do
      let(:params) { 'vaccine' }
      let(:response_body) do
        {
          'USA' => { 'total_vaccinations' => 500_000_000 },
          'IND' => { 'total_vaccinations' => 1_500_000_000 }
        }.to_json
      end

      before do
        stub_request(:get, ENV.fetch('VACCINATION_API', 'https://example.com/vaccine'))
          .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns vaccination data' do
        result = service.retrieve_data

        expect(result).to be_a(Hash)
        expect(result.keys).to include('USA')
      end
    end

    describe 'timeline data endpoint' do
      let(:params) { 'timeline' }
      let(:response_body) do
        {
          'data' => [
            { 'date' => '2021-06-01', 'active' => 1000 }
          ]
        }.to_json
      end

      before do
        stub_request(:get, ENV.fetch('CORONA_TIMELINE_API', 'https://corona-api.com/timeline'))
          .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns timeline data' do
        result = service.retrieve_data

        expect(result).to be_a(Hash)
        expect(result['data']).to be_an(Array)
      end
    end

    describe 'error handling' do
      let(:params) { 'all' }

      context 'when API returns 500 error' do
        before do
          stub_request(:get, "#{ENV.fetch('DISEASES_API', 'https://disease.sh/v3/covid-19/')}all")
            .to_return(status: 500, body: 'Internal Server Error')
        end

        it 'returns nil and logs error' do
          expect(Rails.logger).to receive(:error).with(/API Error/)
          result = service.retrieve_data

          expect(result).to be_nil
        end
      end

      context 'when API returns invalid JSON' do
        before do
          stub_request(:get, "#{ENV.fetch('DISEASES_API', 'https://disease.sh/v3/covid-19/')}all")
            .to_return(status: 200, body: 'not valid json')
        end

        it 'returns nil and logs error' do
          expect(Rails.logger).to receive(:error).with(/JSON parse error/)
          result = service.retrieve_data

          expect(result).to be_nil
        end
      end

      context 'when network timeout occurs' do
        before do
          stub_request(:get, "#{ENV.fetch('DISEASES_API', 'https://disease.sh/v3/covid-19/')}all")
            .to_timeout
        end

        it 'returns nil and logs error' do
          expect(Rails.logger).to receive(:error).with(/API Error/)
          result = service.retrieve_data

          expect(result).to be_nil
        end
      end
    end
  end
end
