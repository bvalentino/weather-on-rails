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
end
