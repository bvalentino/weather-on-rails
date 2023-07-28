# frozen_string_literal: true

# This decorator provides a consistent interface for accessing the `zip_code`,
# `city`, and `country_code` from the geocode data.
class GeocodeDecorator < SimpleDelegator
  def zip_code
    components['postcode']
  end

  def city
    components['city']
  end

  def country_code
    components['country_code']
  end
end
