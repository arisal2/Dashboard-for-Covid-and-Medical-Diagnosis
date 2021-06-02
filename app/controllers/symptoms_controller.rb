# frozen_string_literal: true

# Controller to handle symptom
class SymptomsController < ApplicationController
  before_action :authenticate_user!

  def index
    respond_to do |format|
      format.html
      format.json { render json: SymptomDatatable.new(params) }
    end
  end

  def diagnosis
    @diagnosis_data = ReportService.process_diagnosis_data(submit_params)
    if @diagnosis_data.blank?
      flash[:notice] = 'Invalid Input'
      redirect_to symptoms_path
    else
      flash[:notice] = 'Here are the diagnosis for the symptoms'
    end
  rescue StandardError => e
    flash[:error] = "Error: #{e.message}"
    redirect_to symptoms_path
  end

  def submit_params
    params.permit(:symptoms, :gender, :year, :token)
  end
end
