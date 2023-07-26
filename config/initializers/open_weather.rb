# frozen_string_literal: true

OpenWeather::Client.configure do |config|
  config.api_key = ENV.fetch('OPEN_WEATHER_API_KEY', nil)
end
