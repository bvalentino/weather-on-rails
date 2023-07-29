# frozen_string_literal: true

# This service object is used to fetch the current weather for a given zip code
# (if present), city, and country code.
# It uses the OpenWeather API, and caches the results for 30 minutes.
# If the API key is invalid, or the API returns no results for the given
# location, the `outcome` will be invalid.
#
# The response is wrapped in a decorator object, `WeatherDecorator`.
#
# Example usage:
#   outcome = Weather::Fetch.run(zip_code: '95014')
#   current_weather = outcome.result # => ['main', ...]
#   outcome.was_cached # => false
#   outcome.last_updated_at # => 2023-01-01 12:00:00 -0800
#
module Weather
  class Fetch < ActiveInteraction::Base
    string :zip_code, default: nil
    string :city, default: nil
    string :country_code, default: 'us'

    validates :zip_code, presence: true, if: -> { city.blank? }
    validates :city, presence: true, if: -> { zip_code.blank? }
    validates :country_code, presence: true

    attr_reader :was_cached, :last_updated_at

    def execute
      response = fetch_cached_current_weather || fetch_current_weather_and_cache

      WeatherDecorator.new(
        response,
        was_cached: @was_cached,
        last_updated_at: @last_updated_at
      )
    rescue OpenWeather::Errors::Fault => e
      errors.add(:base, e.message['message'])
    rescue Faraday::ResourceNotFound => e
      errors.add(:base, e.message)
    end

    private

      # Returns the cache key for the current weather, based on the zip code and country code.
      def cache_key
        "weather/#{country_code.upcase}/#{zip_code || city}"
      end

      # Requests the current weather from the OpenWeather API.
      def fetch_current_weather
        location = {
          city:,
          zip: zip_code,
          country: country_code
        }.compact

        OpenWeather::Client.new.current_weather(location)
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
