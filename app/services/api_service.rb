# frozen_string_literal: true

# Service to fetch API data
class ApiService
  API_MEDIC_SANDBOX_API_LOGIN = 'https://sandbox-authservice.priaid.ch/login'

  def initialize(params:)
    @params = params
  end

  def retrieve_data
    parsed_response
  end

  private

  attr_reader :params

  def select_api
    case params
    when 'all', 'countries', 'continents'
      call_api("#{ENV.fetch('DISEASES_API', nil)}#{params}")
    when 'vaccine'
      call_api(ENV.fetch('VACCINATION_API', nil))
    when 'timeline'
      call_api(ENV.fetch('CORONA_TIMELINE_API', nil))
    else
      call_api(construct_url)
    end
  end

  def call_api(url)
    return nil if url.blank?

    conn = Faraday.new do |f|
      f.request :url_encoded
      f.response :raise_error
    end

    response = conn.get(url)
    response.body
  rescue Faraday::Error => e
    Rails.logger.error "API Error: #{e.message}"
    nil
  end

  def construct_url
    token = retrieve_token
    return nil if token.blank?

    url = "#{ENV.fetch('API_MEDIC_SANDBOX_API_DIAGNOSIS', nil)}?symptoms=[#{params[:symptoms]}]"
    url += "&gender=#{params[:gender]}"
    url += "&year_of_birth=#{params[:year]}&token=#{token}&format=json&language=en-gb"

    url
  end

  def retrieve_token
    conn = Faraday.new do |f|
      f.request :url_encoded
    end

    token_response = conn.post(API_MEDIC_SANDBOX_API_LOGIN) do |req|
      req.headers['Authorization'] = ENV.fetch('AUTHORIZATION', nil)
    end

    JSON.parse(token_response.body)['Token']
  rescue Faraday::Error, JSON::ParserError => e
    Rails.logger.error "Token retrieval error: #{e.message}"
    nil
  end

  def parsed_response
    response = select_api
    return nil if response.blank?

    JSON.parse(response)
  rescue JSON::ParserError => e
    Rails.logger.error "JSON parse error: #{e.message}"
    nil
  end
end
