# frozen_string_literal: true

require 'rails_helper'

describe 'User visits current weather page' do
  let(:zip_code) { '95014' }
  let(:country_code) { 'us' }
  let(:api_key) { OpenWeather::Client.new.api_key }
  let(:api_response) do
    JSON.parse(Rails.root.join('spec/fixtures/open_weather/current_weather/valid.json').read)
  end

  before do
    stub_request(:get, "https://api.openweathermap.org/data/2.5/weather?appid=#{api_key}&zip=#{zip_code},#{country_code}")
      .to_return(
        status: 200,
        body: api_response.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  context 'when the weather information is not cached' do
    before do
      visit current_weather_path(zip_code:, country_code:)
    end

    it 'shows the city name' do
      expect(page).to have_text('Cupertino')
    end

    it 'shows the country code' do
      expect(page).to have_text(country_code.upcase)
    end

    it 'shows the current temperate' do
      expect(page).to have_text('57 °F')
    end

    it 'shows the high and low' do
      expect(page).to have_text("High/Low\n60 °F / 51 °F")
    end

    it 'shows the feels like temperature' do
      expect(page).to have_text("Feels like\n56 °F")
    end

    it 'shows the humidity' do
      expect(page).to have_text("Humidity\n84%")
    end

    it 'shows the pressure' do
      expect(page).to have_text("Pressure\n1014 mb")
    end

    it 'shows that the data was not cached' do
      expect(page).to have_text('Weather information up to date')
    end
  end

  context 'when the weather information is cached' do
    before do
      allow(Rails.cache).to receive(:read).and_return(
        [Weather::Fetch.run!(zip_code:), Time.zone.now]
      )

      visit current_weather_path(zip_code:, country_code:)
    end

    it 'shows that the data was cached' do
      expect(page).to have_text('Weather information last updated')
    end
  end
end
