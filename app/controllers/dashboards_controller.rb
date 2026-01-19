# frozen_string_literal: true

# Controller to handle covid dashboard actions
class DashboardsController < ApplicationController
  def world_data
    @world_data = ReportService.process_table_data('countries')
    @general_data = ReportService.process_table_data('all')

    respond_to do |format|
      format.html
      format.json { render json: { world_data: @world_data, general_data: @general_data } }
    end
  rescue StandardError => e
    respond_to do |format|
      format.html { flash[:error] = e.message.to_s }
      format.json { render json: { error: e.message }, status: :bad_request }
    end
  end

  def vaccination
    @vaccination_data = ReportService.process_table_data('vaccine')
  rescue StandardError => e
    flash[:error] = e.message.to_s
  end

  def covid_chart
    @area_chart = ReportService.process_area_chart_data('timeline')
    @bar_chart = ReportService.process_bar_chart_data('continents')
  rescue StandardError => e
    flash[:error] = e.message.to_s
  end

  def world_map
    @covid_cases_map_data = ReportService.process_covid_map_data('countries', 'cases')
    @covid_death_map_data = ReportService.process_covid_map_data('countries', 'deaths')
  rescue StandardError => e
    flash[:error] = e.message.to_s
  end
end
