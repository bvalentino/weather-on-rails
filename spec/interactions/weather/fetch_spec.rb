# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Weather::Fetch do
  let(:zip_code) { '95014' }
  let(:city) { 'Cupertino' }
  let(:api_key) { OpenWeather::Client.new.api_key }

  context 'when both zip_code and city are passed' do
    let(:api_response) do
      JSON.parse(Rails.root.join('spec/fixtures/open_weather/current_weather/valid.json').read)
    end

    before do
      stub_request(:get, "https://api.openweathermap.org/data/2.5/weather?appid=#{api_key}&city=#{city}&zip=#{zip_code},us")
        .to_return(
          status: 200,
          body: api_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'is valid' do
      outcome = described_class.run(zip_code:, city:)

      expect(outcome).to be_valid
    end

    it 'returns the current weather' do
      outcome = described_class.run(zip_code:, city:)

      expect(outcome.result.main).to eq(api_response['main'])
    end
  end

  context 'when only zip_code is passed' do
    let(:api_response) do
      JSON.parse(Rails.root.join('spec/fixtures/open_weather/current_weather/valid.json').read)
    end

    before do
      stub_request(:get, "https://api.openweathermap.org/data/2.5/weather?appid=#{api_key}&zip=#{zip_code},us")
        .to_return(
          status: 200,
          body: api_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'is valid' do
      outcome = described_class.run(zip_code:)

      expect(outcome).to be_valid
    end

    it 'returns the current weather' do
      outcome = described_class.run(zip_code:)

      expect(outcome.result.main).to eq(api_response['main'])
    end
  end

  context 'when no zip_code but city is passed' do
    let(:api_response) do
      JSON.parse(Rails.root.join('spec/fixtures/open_weather/current_weather/valid.json').read)
    end

    before do
      stub_request(:get, "https://api.openweathermap.org/data/2.5/weather?appid=#{api_key}&q=#{city},us")
        .to_return(
          status: 200,
          body: api_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'is valid' do
      outcome = described_class.run(city:)

      expect(outcome).to be_valid
    end

    it 'returns the current weather' do
      outcome = described_class.run(city:)

      expect(outcome.result.main).to eq(api_response['main'])
    end
  end

  context 'when the API key is invalid' do
    let(:api_response) do
      JSON.parse(Rails.root.join('spec/fixtures/open_weather/current_weather/invalid_api_key.json').read)
    end

    before do
      OpenWeather::Client.configure do |c|
        c.api_key = nil
      end

      stub_request(:get, "https://api.openweathermap.org/data/2.5/weather?city=#{city}&zip=#{zip_code},us")
        .to_return(
          status: 401,
          body: { cod: 401, message: api_response }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'is invalid' do
      outcome = described_class.run(zip_code:, city:)

      expect(outcome).to be_invalid
    end
  end

  context 'when the zip code is invalid' do
    let(:api_response) do
      JSON.parse(Rails.root.join('spec/fixtures/open_weather/current_weather/not_found.json').read)
    end

    before do
      stub_request(:get, "https://api.openweathermap.org/data/2.5/weather?appid=#{api_key}&city=#{city}&zip=#{zip_code},us")
        .to_return(
          status: 404,
          body: { cod: 404, message: api_response }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'is invalid' do
      outcome = described_class.run(zip_code:, city:)

      expect(outcome).to be_invalid
    end
  end
end
