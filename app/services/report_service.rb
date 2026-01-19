# frozen_string_literal: true

# Service to process COVID-19 and medical diagnosis reports
class ReportService
  class ReportServiceError < StandardError; end

  DIAGNOSIS_ERROR = 'symptoms are invalid or symptoms are in invalid format!'
  NO_DATA_ERROR = 'Data not available, please try again!'

  class << self
    # Process table data for world/country statistics
    # @param params [String] API endpoint parameter ('all', 'countries', etc.)
    # @return [Hash, Array] Parsed API response data
    # @raise [ReportServiceError] when data is unavailable
    def process_table_data(params)
      result = fetch_data(params)
      raise ReportServiceError, NO_DATA_ERROR if result.blank?

      result
    end

    # Process timeline data for area charts
    # @param params [String] API endpoint parameter ('timeline')
    # @return [Hash] Chart data with date, active, deaths, recovered arrays
    # @raise [ReportServiceError] when data is unavailable
    def process_area_chart_data(params)
      timeline_data = fetch_data(params)
      raise ReportServiceError, NO_DATA_ERROR if timeline_data.blank?

      build_area_chart_data(timeline_data)
    end

    # Process continent data for bar charts
    # @param params [String] API endpoint parameter ('continents')
    # @return [Hash] Chart data with continents, population, tests arrays
    # @raise [ReportServiceError] when data is unavailable
    def process_bar_chart_data(params)
      continents_data = fetch_data(params)
      raise ReportServiceError, NO_DATA_ERROR if continents_data.blank?

      build_bar_chart_data(continents_data)
    end

    # Process country data for world map visualization
    # @param params [String] API endpoint parameter ('countries')
    # @param flag [String] Data field to visualize ('cases' or 'deaths')
    # @return [String] JSON array of country map data
    # @raise [ReportServiceError] when data is unavailable
    def process_covid_map_data(params, flag)
      countries_data = fetch_data(params)
      raise ReportServiceError, NO_DATA_ERROR if countries_data.blank?

      build_map_data(countries_data, flag).to_json
    end

    # Process medical diagnosis based on symptoms
    # @param params [Hash] Diagnosis parameters with symptoms, gender, year
    # @return [Array, nil] Diagnosis results or nil if invalid
    def process_diagnosis_data(params)
      diagnosis_data = fetch_data(params)
      return nil if diagnosis_data.nil? || diagnosis_data.eql?(DIAGNOSIS_ERROR)

      diagnosis_data
    end

    private

    # Fetch data from API service
    # @param params [String, Hash] API parameters
    # @return [Hash, Array, nil] Parsed API response
    def fetch_data(params)
      ApiService.new(params: params).retrieve_data
    rescue StandardError => e
      Rails.logger.error("ReportService API error: #{e.message}")
      nil
    end

    # Build area chart data structure from timeline response
    # @param timeline_data [Hash] Raw timeline API response
    # @return [Hash] Formatted chart data
    def build_area_chart_data(timeline_data)
      chart_data = { date: [], active: [], deaths: [], recovered: [] }

      timeline_data.fetch('data', []).reverse_each do |timeline|
        chart_data[:date] << timeline['date']
        chart_data[:active] << timeline['active'].to_i
        chart_data[:deaths] << timeline['deaths'].to_i
        chart_data[:recovered] << timeline['recovered'].to_i
      end

      chart_data
    end

    # Build bar chart data structure from continents response
    # @param continents_data [Array] Raw continents API response
    # @return [Hash] Formatted chart data
    def build_bar_chart_data(continents_data)
      continents_data.each_with_object({ continents: [], population: [], tests: [] }) do |continent, chart|
        chart[:continents] << continent['continent']
        chart[:population] << continent['population'].to_i
        chart[:tests] << continent['tests'].to_i
      end
    end

    # Build map data structure from countries response
    # @param countries_data [Array] Raw countries API response
    # @param flag [String] Data field to extract
    # @return [Array] Formatted map data
    def build_map_data(countries_data, flag)
      countries_data.filter_map do |country|
        value = country[flag].to_i
        next if value.zero?

        country_info = country['countryInfo'] || {}
        {
          code3: country_info['iso3'],
          name: country['country'],
          value: value,
          code: country_info['iso2']
        }
      end
    end
  end
end
