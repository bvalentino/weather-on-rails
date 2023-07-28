# frozen_string_literal: true

class WeathersController < ApplicationController
  def show
    outcome = Geocoder::Geocode.run(address:)
    return render('weathers/errors/geocode_not_found') if outcome.invalid?

    @geocode = outcome.result
  end

  def current
    outcome = Weather::Fetch.run(zip_code:, city:, country_code:)
    return render('weathers/errors/weather_not_found') if outcome.invalid?

    @weather = outcome.result
  end

  private

    def address
      @address ||= params[:address]
    end

    def zip_code
      @zip_code ||= params[:zip_code]
    end

    def city
      @city ||= params[:city]
    end

    def country_code
      @country_code ||= params[:country_code]
    end
end
