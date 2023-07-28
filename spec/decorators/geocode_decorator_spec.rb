# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GeocodeDecorator do
  subject(:geocode_decorator) { described_class.new(geocoder.geocode(address).first) }

  let(:address) { '1 Infinite Loop, Cupertino, CA' }
  let(:geocoder) { OpenCage::Geocoder.new(api_key: ENV.fetch('OPEN_CAGE_API_KEY')) }
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

  it '#zip_code' do
    expect(geocode_decorator.zip_code).to eq('95014')
  end

  it '#city' do
    expect(geocode_decorator.city).to eq('Cupertino')
  end

  it '#country_code' do
    expect(geocode_decorator.country_code).to eq('us')
  end
end
