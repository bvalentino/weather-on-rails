# frozen_string_literal: true

require 'rails_helper'

describe 'User visits current weather page' do
  let(:zip_code) { '95014' }
  let(:api_response) do
    {
      'coord' => { 'lon' => -122.0449, 'lat' => 37.318 },
      'weather' => [],
      'base' => 'stations',
      'main' => { 'temp' => 294.49, 'feels_like' => 298.48, 'temp_min' => 287.88, 'temp_max' => 298.13,
                  'pressure' => 1015, 'humidity' => 68 },
      'visibility' => 10_000,
      'wind' => { 'speed' => 3.6, 'deg' => 360 },
      'clouds' => { 'all' => 20 },
      'timezone' => -25_200,
      'id' => 0,
      'name' => 'Cupertino',
      'cod' => 200
    }
  end

  before do
    stub_request(:get, "https://api.openweathermap.org/data/2.5/weather?appid=#{OpenWeather::Client.new.api_key}&zip=#{zip_code},us")
      .to_return(
        status: 200,
        body: api_response.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    visit current_weather_path(zip_code:, country_code: 'us')
  end

  it 'shows the zip code' do
    expect(page).to have_text(zip_code)
  end

  it 'shows the country code' do
    expect(page).to have_text('US')
  end

  it 'shows the current temperate' do
    expect(page).to have_text('Current temperature: 70 °F')
  end

  it 'shows the high and low' do
    expect(page).to have_text('High/Low: 77 °F / 59 °F')
  end

  it 'shows the feels like temperature' do
    expect(page).to have_text('Feels like: 78 °F')
  end

  it 'shows the humidity' do
    expect(page).to have_text('Humidity: 68%')
  end

  it 'shows the pressure' do
    expect(page).to have_text('Pressure: 1015 mb')
  end
end
