# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Weather::Fetch do
  let(:zip_code) { '95014' }
  let(:api_key) { OpenWeather::Client.new.api_key }

  context 'when the API key is valid' do
    let(:api_response) do
      { 'weather' => [{ 'main' => 'Clear' }] }
    end

    before do
      stub_request(:get, "https://api.openweathermap.org/data/2.5/weather?appid=#{api_key}&zip=#{zip_code},us")
        .to_return(
          status: 200,
          body: api_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'returns the current weather' do
      expect(described_class.run!(zip_code:)).to eq(api_response)
    end
  end

  context 'when the API key is invalid' do
    let(:api_response) do
      'Invalid API key. Please see https://openweathermap.org/faq#error401 for more info.'
    end

    before do
      OpenWeather::Client.configure do |c|
        c.api_key = nil
      end

      stub_request(:get, "https://api.openweathermap.org/data/2.5/weather?zip=#{zip_code},us")
        .to_return(
          status: 401,
          body: { cod: 401, message: api_response }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'raises an error' do
      expect { described_class.run!(zip_code:) }
        .to raise_error(OpenWeather::Errors::Fault, api_response)
    end
  end

  context 'when the zip code is invalid' do
    let(:api_response) { 'the server responded with status 404' }

    before do
      stub_request(:get, "https://api.openweathermap.org/data/2.5/weather?appid=#{api_key}&zip=#{zip_code},us")
        .to_return(
          status: 404,
          body: { cod: 404, message: api_response }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'raises an error' do
      expect { described_class.run!(zip_code:) }
        .to raise_error(Faraday::ResourceNotFound, api_response)
    end
  end
end
