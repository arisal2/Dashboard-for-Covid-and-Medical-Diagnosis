# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe PotentialUsersController, type: :controller do
  before do
    user = FactoryBot.create(:user)
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'GET #index' do
    context 'when logged in' do
      let(:potential_users_index) { get :index }

      it 'returns http success' do
        potential_users_index
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'POST #import' do
    let(:potential_users_import) { post :import, params: params }
    context 'when logged in' do
      let(:params) { { file: Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/example.csv').to_s) } }

      it 'redirects to the home page' do
        potential_users_import
        expect(response).to redirect_to potential_users_path
      end

      it 'adds a flash notice' do
        potential_users_import
        expect(flash[:notice]).to eq 'File was successfully imported.'
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
