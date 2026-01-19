# frozen_string_literal: true

Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Sidekiq Web UI
  require 'sidekiq/web'
  require 'sidekiq/cron/web'
  mount Sidekiq::Web => '/sidekiq'

  # Authentication
  devise_for :users

  # Home
  get 'home/index'

  # Dashboard routes
  resources :dashboards, only: [] do
    collection do
      get :world_data
      get :world_map
      get :vaccination
      get :covid_chart
    end
  end

  # Symptoms/Diagnosis routes
  resources :symptoms, only: [:index] do
    collection do
      get :diagnosis
    end
  end

  # Potential users (marketing)
  resources :potential_users do
    collection do
      post :import
    end
  end

  # Root
  root to: 'home#index'
end
