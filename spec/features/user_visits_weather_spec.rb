# frozen_string_literal: true

require 'rails_helper'

describe 'User visits weather page' do
  let(:address) { '95014' }
  let(:geocode_api_response) do
    JSON.parse(Rails.root.join('spec/fixtures/open_cage/geocode/valid.json').read)
  end
  let(:weather_api_response) do
    JSON.parse(Rails.root.join('spec/fixtures/open_weather/current_weather/valid.json').read)
  end

  before do
    stub_request(:get, "https://api.opencagedata.com/geocode/v1/json?key=#{ENV.fetch('OPEN_CAGE_API_KEY', nil)}&q=#{CGI.escape(address)}") # rubocop:disable Metrics/LineLength
      .to_return(
        status: 200,
        body: geocode_api_response.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    stub_request(:get, "https://api.openweathermap.org/data/2.5/weather?appid=#{OpenWeather::Client.new.api_key}&zip=#{address}")
      .to_return(
        status: 200,
        body: weather_api_response.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    visit weather_path(address:)
  end

  it 'shows a loading indicator' do
    expect(page).to have_text('Loading')
  end

  it 'has a turbo-frame tag for weather' do
    expect(page).to have_css('turbo-frame#weather')
  end

  it 'has a turbo-frame tag for async details' do
    src_url = current_weather_path(zip_code: '95014', city: 'Cupertino', country_code: 'us')

    expect(page).to have_css("turbo-frame#details[src='#{src_url}']")
  end
end
