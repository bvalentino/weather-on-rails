# frozen_string_literal: true

# This service object is used to fetch geocode data for an address. It uses the
# OpenCage Geocoder API. Given an address, it returns the closest matching geocode.
# This includes the city, state, zip code, and country.
# The geocode data is cached to prevent excessive API calls.
# If the API returns no results for the address, the `outcome` will be invalid.
#
# This service object also provides additional helper methods for `zip_code`,
# `city`, and `country_code`.
#
# Example usage:
#   outcome = Geocoder::Geocode.run(address: '1 Infinite Loop, Cupertino, CA')
#   outcome.valid? # => true
#   outcome.zip_code # => '95014'
#   outcome.city # => 'Cupertino'
#   outcome.country_code # => 'us'
#
module Geocoder
  class Geocode < ActiveInteraction::Base
    string :address

    def execute
      @geocode = Rails.cache.fetch(cache_key) do
        response = geocoder.geocode(address)
        raise NoGeocodeDataError, "No geocode data available for #{address}" if response.blank?

        response.first
      end
    rescue NoGeocodeDataError => e
      errors.add(:base, e.message)
    end

    def zip_code
      @geocode&.components&.fetch('postcode', nil)
    end

    def city
      @geocode&.components&.fetch('city', nil)
    end

    def country_code
      @geocode&.components&.fetch('country_code', nil)
    end

    private

      def geocoder
        @geocoder ||= OpenCage::Geocoder.new(
          api_key: ENV.fetch('OPEN_CAGE_API_KEY')
        )
      end

      # The cache key is based on the address. But we're hashing it so that
      # it's a fixed length, and doesn't contain any characters that are
      # invalid for a cache key.
      def cache_key
        hashed_address = Digest::SHA256.hexdigest(address)

        "geocode/#{hashed_address}"
      end
  end
end

# The `NoGeocodeDataError` is a custom exception that is raised when the
# OpenCage Geocoder API returns no results for an address.
class NoGeocodeDataError < StandardError; end
