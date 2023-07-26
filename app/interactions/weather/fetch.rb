# frozen_string_literal: true

# Fetches the current weather for a given zip code and country code.
# Uses the OpenWeather API.
module Weather
  class Fetch < ActiveInteraction::Base
    string :zip_code
    string :country_code, default: 'us'

    def execute
      OpenWeather::Client.new.current_weather(
        zip: zip_code,
        country: country_code
      )
    end
  end
end
