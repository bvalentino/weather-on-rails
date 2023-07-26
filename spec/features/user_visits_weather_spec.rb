# frozen_string_literal: true

require 'rails_helper'

describe 'User visits weather page' do
  let(:zip_code) { '95014' }

  before do
    visit weather_path(zip_code:)
  end

  it 'shows the zip code' do
    expect(page).to have_text(zip_code)
  end

  it 'shows the country code' do
    expect(page).to have_text('US')
  end

  it 'shows a loading indicator' do
    expect(page).to have_text('Loading...')
  end
end
