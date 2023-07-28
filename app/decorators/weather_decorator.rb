# frozen_string_literal: true

# This decorator provides a consistent interface for accessing the weather data
# returned by the OpenWeather API.
# It also provides a way to know if the data was cached, and for how long.
# And it provides a way to change the temperature unit.
class WeatherDecorator < SimpleDelegator
  FARENHEIT = 'f'
  CELCIUS = 'c'

  def initialize(weather, was_cached: false, last_updated_at: nil, temperature_unit: FARENHEIT)
    super(weather)

    @was_cached = was_cached
    @last_updated_at = last_updated_at
    @temperature_unit = temperature_unit
  end

  attr_reader :was_cached, :last_updated_at
  attr_accessor :temperature_unit

  def country_code
    sys.country
  end

  def location
    "#{name}, #{country_code}"
  end

  def temperature
    main.public_send("temp_#{temperature_unit}")
  end

  def temperature_max
    main.public_send("temp_max_#{temperature_unit}")
  end

  def temperature_min
    main.public_send("temp_min_#{temperature_unit}")
  end

  def feels_like
    main.public_send("feels_like_#{temperature_unit}")
  end

  delegate :humidity, :pressure,
           to: :main
end
