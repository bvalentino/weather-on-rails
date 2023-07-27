# frozen_string_literal: true

Rails.application.routes.draw do
  resource :weather, only: [:show] do
    get :current
  end

  root "home#index"
end
