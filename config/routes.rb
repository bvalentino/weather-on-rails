# frozen_string_literal: true

Rails.application.routes.draw do
  resource :weather, only: [:show] do
    get 'current/:zip_code/:country_code', action: :current, as: :current
  end

  root "home#index"
end
