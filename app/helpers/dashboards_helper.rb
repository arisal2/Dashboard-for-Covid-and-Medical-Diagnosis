# frozen_string_literal: true

# Helper for Dashboard
module DashboardsHelper
  def latest_update
    return if strip_latest_update_time.blank?

    Time.zone.at(strip_latest_update_time).strftime('%d/%m/%Y')
  end

  def strip_latest_update_time
    @general_data&.dig('updated').to_s[0...-3].to_i
  end

  def world_data_top_section(value)
    number_with_delimiter(@general_data&.dig(value), delimiter: ',')
  end

  def vaccination_top_section(value)
    number_with_delimiter(@vaccination_data&.dig('OWID_WRL', value), delimiter: ',')
  end

  def area_chart_data(value)
    return [0] if @area_chart.blank?

    @area_chart[value]
  end

  def bar_chart_data(value)
    return [0] if @bar_chart.blank?

    @bar_chart[value]
  end
end
