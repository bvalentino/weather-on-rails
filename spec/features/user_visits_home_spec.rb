# frozen_string_literal: true

require 'rails_helper'

describe 'User visits home page' do
  it 'has a form to enter the address' do
    visit root_path

    expect(page).to have_field('address')
  end
end
