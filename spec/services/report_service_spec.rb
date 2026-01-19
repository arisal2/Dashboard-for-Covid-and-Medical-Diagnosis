# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReportService do
  describe '.process_table_data' do
    context 'when API returns valid data' do
      let(:response_data) do
        {
          'updated' => 1_640_000_000_000,
          'cases' => 300_000_000,
          'todayCases' => 500_000,
          'deaths' => 5_000_000
        }
      end

      before do
        allow_any_instance_of(ApiService).to receive(:retrieve_data).and_return(response_data)
      end

      it 'returns the table data' do
        result = described_class.process_table_data('all')

        expect(result).to include(
          'cases' => 300_000_000,
          'deaths' => 5_000_000
        )
      end
    end

    context 'when API returns blank data' do
      before do
        allow_any_instance_of(ApiService).to receive(:retrieve_data).and_return(nil)
      end

      it 'raises ReportServiceError' do
        expect { described_class.process_table_data('all') }
          .to raise_error(ReportService::ReportServiceError, ReportService::NO_DATA_ERROR)
      end
    end
  end

  describe '.process_area_chart_data' do
    context 'when API returns valid timeline data' do
      let(:timeline_response) do
        {
          'data' => [
            { 'date' => '2021-06-01', 'active' => 1000, 'deaths' => 50, 'recovered' => 500 },
            { 'date' => '2021-06-02', 'active' => 1100, 'deaths' => 55, 'recovered' => 550 },
            { 'date' => '2021-06-03', 'active' => 1200, 'deaths' => 60, 'recovered' => 600 }
          ]
        }
      end

      before do
        allow_any_instance_of(ApiService).to receive(:retrieve_data).and_return(timeline_response)
      end

      it 'returns formatted area chart data' do
        result = described_class.process_area_chart_data('timeline')

        expect(result).to be_a(Hash)
        expect(result.keys).to contain_exactly(:date, :active, :deaths, :recovered)
      end

      it 'reverses the data order (oldest first)' do
        result = described_class.process_area_chart_data('timeline')

        expect(result[:date].first).to eq('2021-06-03')
        expect(result[:date].last).to eq('2021-06-01')
      end

      it 'converts values to integers' do
        result = described_class.process_area_chart_data('timeline')

        expect(result[:active]).to all(be_an(Integer))
        expect(result[:deaths]).to all(be_an(Integer))
        expect(result[:recovered]).to all(be_an(Integer))
      end
    end

    context 'when API returns empty data' do
      before do
        allow_any_instance_of(ApiService).to receive(:retrieve_data).and_return({})
      end

      it 'raises ReportServiceError' do
        expect { described_class.process_area_chart_data('timeline') }
          .to raise_error(ReportService::ReportServiceError)
      end
    end
  end

  describe '.process_bar_chart_data' do
    context 'when API returns valid continent data' do
      let(:continents_response) do
        [
          { 'continent' => 'Asia', 'population' => 4_000_000_000, 'tests' => 500_000_000 },
          { 'continent' => 'Europe', 'population' => 750_000_000, 'tests' => 300_000_000 },
          { 'continent' => 'North America', 'population' => 600_000_000, 'tests' => 400_000_000 }
        ]
      end

      before do
        allow_any_instance_of(ApiService).to receive(:retrieve_data).and_return(continents_response)
      end

      it 'returns formatted bar chart data' do
        result = described_class.process_bar_chart_data('continents')

        expect(result).to be_a(Hash)
        expect(result.keys).to contain_exactly(:continents, :population, :tests)
      end

      it 'includes all continents' do
        result = described_class.process_bar_chart_data('continents')

        expect(result[:continents]).to include('Asia', 'Europe', 'North America')
        expect(result[:continents].length).to eq(3)
      end

      it 'converts population and tests to integers' do
        result = described_class.process_bar_chart_data('continents')

        expect(result[:population]).to all(be_an(Integer))
        expect(result[:tests]).to all(be_an(Integer))
      end
    end

    context 'when API returns nil' do
      before do
        allow_any_instance_of(ApiService).to receive(:retrieve_data).and_return(nil)
      end

      it 'raises ReportServiceError' do
        expect { described_class.process_bar_chart_data('continents') }
          .to raise_error(ReportService::ReportServiceError, ReportService::NO_DATA_ERROR)
      end
    end
  end

  describe '.process_covid_map_data' do
    context 'when API returns valid country data' do
      let(:countries_response) do
        [
          {
            'country' => 'USA',
            'countryInfo' => { 'iso3' => 'USA', 'iso2' => 'US' },
            'cases' => 50_000_000,
            'deaths' => 800_000
          },
          {
            'country' => 'India',
            'countryInfo' => { 'iso3' => 'IND', 'iso2' => 'IN' },
            'cases' => 35_000_000,
            'deaths' => 500_000
          },
          {
            'country' => 'Test Country',
            'countryInfo' => { 'iso3' => 'TST', 'iso2' => 'TS' },
            'cases' => 0,
            'deaths' => 0
          }
        ]
      end

      before do
        allow_any_instance_of(ApiService).to receive(:retrieve_data).and_return(countries_response)
      end

      it 'returns JSON string' do
        result = described_class.process_covid_map_data('countries', 'cases')

        expect(result).to be_a(String)
        expect { JSON.parse(result) }.not_to raise_error
      end

      it 'filters out countries with zero values' do
        result = JSON.parse(described_class.process_covid_map_data('countries', 'cases'))

        expect(result.length).to eq(2)
        expect(result.pluck('name')).not_to include('Test Country')
      end

      it 'includes country code and value' do
        result = JSON.parse(described_class.process_covid_map_data('countries', 'cases'))
        usa = result.find { |c| c['name'] == 'USA' }

        expect(usa['code3']).to eq('USA')
        expect(usa['code']).to eq('US')
        expect(usa['value']).to eq(50_000_000)
      end

      it 'works with deaths flag' do
        result = JSON.parse(described_class.process_covid_map_data('countries', 'deaths'))
        usa = result.find { |c| c['name'] == 'USA' }

        expect(usa['value']).to eq(800_000)
      end
    end

    context 'when API returns nil' do
      before do
        allow_any_instance_of(ApiService).to receive(:retrieve_data).and_return(nil)
      end

      it 'raises ReportServiceError' do
        expect { described_class.process_covid_map_data('countries', 'cases') }
          .to raise_error(ReportService::ReportServiceError)
      end
    end
  end

  describe '.process_diagnosis_data' do
    context 'when API returns valid diagnosis' do
      let(:diagnosis_response) do
        [
          {
            'Issue' => {
              'ID' => 281,
              'Name' => 'Food poisoning',
              'Accuracy' => 90,
              'Icd' => 'A05;A02;A03;A04',
              'IcdName' => 'Foodborne illness',
              'ProfName' => 'Foodborne illness',
              'Ranking' => 1
            },
            'Specialisation' => [
              { 'ID' => 15, 'Name' => 'General practice', 'SpecialistID' => 0 }
            ]
          }
        ]
      end

      before do
        allow_any_instance_of(ApiService).to receive(:retrieve_data).and_return(diagnosis_response)
      end

      it 'returns the diagnosis data' do
        params = { symptoms: '10', gender: 'male', year: '1990' }
        result = described_class.process_diagnosis_data(params)

        expect(result).to be_an(Array)
        expect(result.first['Issue']['Name']).to eq('Food poisoning')
      end
    end

    context 'when API returns error message' do
      before do
        allow_any_instance_of(ApiService).to receive(:retrieve_data)
          .and_return(ReportService::DIAGNOSIS_ERROR)
      end

      it 'returns nil' do
        params = { symptoms: 'invalid', gender: 'male', year: '1990' }
        result = described_class.process_diagnosis_data(params)

        expect(result).to be_nil
      end
    end

    context 'when API returns nil' do
      before do
        allow_any_instance_of(ApiService).to receive(:retrieve_data).and_return(nil)
      end

      it 'returns nil' do
        params = { symptoms: '10', gender: 'male', year: '1990' }
        result = described_class.process_diagnosis_data(params)

        expect(result).to be_nil
      end
    end
  end
end
