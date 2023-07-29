# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Geocoder::Geocode do
  let(:address) { '1 Infinite Loop, Cupertino, CA' }

  describe 'validations' do
    it 'is invalid when address is blank' do
      outcome = described_class.run(address: '')

      expect(outcome).to be_invalid
    end
  end

  context 'when the address is valid' do
    let(:api_response) do
      JSON.parse(Rails.root.join('spec/fixtures/open_cage/geocode/valid.json').read)
    end

    before do
      stub_request(:get, "https://api.opencagedata.com/geocode/v1/json?key=#{ENV.fetch('OPEN_CAGE_API_KEY', nil)}&q=#{CGI.escape(address)}") # rubocop:disable Metrics/LineLength
        .to_return(
          status: 200,
          body: api_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'responds with the zip_code' do
      outcome = described_class.run(address:)

      expect(outcome.result.zip_code).to eq('95014')
    end

    it 'responds with the city' do
      outcome = described_class.run(address:)

      expect(outcome.result.city).to eq('Cupertino')
    end

    it 'responds with the country_code' do
      outcome = described_class.run(address:)

      expect(outcome.result.country_code).to eq('us')
    end
  end

  context 'when the API key is invalid' do
    let(:api_response) do
      JSON.parse(Rails.root.join('spec/fixtures/open_cage/geocode/invalid_api_key.json').read)
    end

    before do
      stub_request(:get, "https://api.opencagedata.com/geocode/v1/json?key=#{ENV.fetch('OPEN_CAGE_API_KEY', nil)}&q=#{CGI.escape(address)}") # rubocop:disable Metrics/LineLength
        .to_return(
          status: 200,
          body: api_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'is invalid' do
      expect(described_class.run(address:)).to be_invalid
    end
  end

  context 'when the address is invalid' do
    let(:api_response) do
      JSON.parse(Rails.root.join('spec/fixtures/open_cage/geocode/no_results.json').read)
    end

    before do
      stub_request(:get, "https://api.opencagedata.com/geocode/v1/json?key=#{ENV.fetch('OPEN_CAGE_API_KEY', nil)}&q=#{CGI.escape(address)}") # rubocop:disable Metrics/LineLength
        .to_return(
          status: 200,
          body: api_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'is invalid' do
      expect(described_class.run(address:)).to be_invalid
    end
  end
end
