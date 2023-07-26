# frozen_string_literal: true

# Fetches the current weather for a given zip code and country code.
# Uses the OpenWeather API, and caches the results for 30 minutes.
# Example usage:
#   outcome = Weather::Fetch.run(zip_code: '95014')
#   current_weather = outcome.result
#   outcome.was_cached
#   outcome.last_updated_at
#
module Weather
  class Fetch < ActiveInteraction::Base
    string :zip_code
    string :country_code, default: 'us'

    attr_reader :was_cached, :last_updated_at

    def execute
      fetch_cached_current_weather || fetch_current_weather_and_cache
    end

    private

      # Returns the cache key for the current weather, based on the zip code and country code.
      def cache_key
        "weather/#{country_code.upcase}/#{zip_code.strip}"
      end

      # Requests the current weather from the OpenWeather API.
      def fetch_current_weather
        OpenWeather::Client.new.current_weather(
          zip: zip_code,
          country: country_code
        )
      end

      # Returns the current weather from the cache, if it exists.
      # It also sets the `last_updated_at` and `was_cached` attributes.
      def fetch_cached_current_weather
        current_weather, @last_updated_at = Rails.cache.read(cache_key)
        @was_cached = true if current_weather

        current_weather
      end

      # Fetches the current weather and caches it for 30 minutes.
      # It also sets the `last_updated_at` and `was_cached` attributes.
      def fetch_current_weather_and_cache(expires_in: 30.minutes)
        current_weather = fetch_current_weather
        @last_updated_at = Time.zone.now
        @was_cached = false

        Rails.cache.write(cache_key, [current_weather, last_updated_at], expires_in:)

        current_weather
      end
  end
end
