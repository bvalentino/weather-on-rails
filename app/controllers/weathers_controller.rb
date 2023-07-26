# frozen_string_literal: true

class WeathersController < ApplicationController
  DEFAULT_COUNTRY_CODE = 'US'

  def show
    set_zip_code
    set_country_code
  end

  def current
    set_zip_code
    set_country_code

    @current_weather = Weather::Fetch.run!(
      zip_code: @zip_code,
      country_code: @country_code
    )
  end

  private

    def set_zip_code
      @zip_code = params[:zip_code]
    end

    def set_country_code
      @country_code = params[:country_code].presence || DEFAULT_COUNTRY_CODE
    end
end
