# frozen_string_literal: true

class WeathersController < ApplicationController
  DEFAULT_COUNTRY_CODE = 'US'

  def show
    set_geocode
  end

  def current
    set_zip_code
    set_city
    set_country_code

    @outcome = Weather::Fetch.run(
      zip_code: @zip_code,
      city: @city,
      country_code: @country_code
    )
    return render 'not_found' if @outcome.invalid?

    @current_weather = @outcome.result
  end

  private

    def set_address
      @address = params[:address]
    end

    def set_zip_code
      @zip_code = params[:zip_code]
    end

    def set_city
      @city = params[:city]
    end

    def set_geocode
      set_address

      @geocode = Geocoder::Geocode.run(address: @address)
    end

    def set_country_code
      @country_code = params[:country_code].presence || DEFAULT_COUNTRY_CODE
    end
end
