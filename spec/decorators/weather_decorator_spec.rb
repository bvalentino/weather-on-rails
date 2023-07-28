# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeatherDecorator do
  subject(:weather_decorator) do
    described_class.new(current_weather, was_cached: true, last_updated_at:, temperature_unit:)
  end

  let(:zip_code) { '95014' }
  let(:api_key) { OpenWeather::Client.new.api_key }
  let(:api_response) do
    JSON.parse(Rails.root.join('spec/fixtures/open_weather/current_weather/valid.json').read)
  end
  let(:current_weather) { OpenWeather::Client.new.current_weather(zip_code:) }
  let(:last_updated_at) { Time.zone.now }
  let(:temperature_unit) { WeatherDecorator::FARENHEIT }

  before do
    stub_request(:get, "https://api.openweathermap.org/data/2.5/weather?appid=#{api_key}&zip_code=#{zip_code}")
      .to_return(
        status: 200,
        body: api_response.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  it '#was_cached' do
    expect(weather_decorator.was_cached).to be(true)
  end

  it '#last_updated_at' do
    expect(weather_decorator.last_updated_at).to eq(last_updated_at)
  end

  it '#country_code' do
    expect(weather_decorator.country_code).to eq('US')
  end

  it '#location' do
    expect(weather_decorator.location).to eq('Cupertino, US')
  end

  it '#humidity' do
    expect(weather_decorator.humidity).to eq(84)
  end

  it '#pressure' do
    expect(weather_decorator.pressure).to eq(1014)
  end

  context 'when the temperature unit is Farenheit' do
    let(:temperature_unit) { WeatherDecorator::FARENHEIT }

    it '#temperature' do
      expect(weather_decorator.temperature).to eq(56.7)
    end

    it '#temperature_max' do
      expect(weather_decorator.temperature_max).to eq(60.19)
    end

    it '#temperature_min' do
      expect(weather_decorator.temperature_min).to eq(51.26)
    end

    it '#feels_like' do
      expect(weather_decorator.feels_like).to eq(56.01)
    end
  end

  context 'when the temperature unit is Celsius' do
    let(:temperature_unit) { WeatherDecorator::CELCIUS }

    it '#temperature' do
      expect(weather_decorator.temperature).to eq(13.72)
    end

    it '#temperature_max' do
      expect(weather_decorator.temperature_max).to eq(15.66)
    end

    it '#temperature_min' do
      expect(weather_decorator.temperature_min).to eq(10.7)
    end

    it '#feels_like' do
      expect(weather_decorator.feels_like).to eq(13.34)
    end
  end
end
