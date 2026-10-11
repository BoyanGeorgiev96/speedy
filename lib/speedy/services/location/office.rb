# frozen_string_literal: true

module Speedy
  module Services
    module Location
      class Office < Speedy::ServiceResource
        include Speedy::Services::Location

        resource_path 'location/office'

        # POST `/location/office`
        def find(country_id: nil, site_id: nil, site_name: nil, name: nil, limit: nil)
          response = post(body: {
            country_id: country_id,
            site_id: site_id,
            site_name: site_name,
            name: name,
            limit: limit
          }.compact)

          collection(response, Speedy::Models::Location::Office)
        end

        # POST `/location/office/{id}`
        def get(id)
          response = post(id.to_s)

          resource(response, Speedy::Models::Location::GetOfficeResponse)
        end

        # POST `/location/office/nearest-offices`
        def nearest(address:, distance: nil, limit: nil, office_type: nil, office_features: nil)
          response = post('nearest-offices', body: {
            address: address,
            distance: distance,
            limit: limit,
            office_type: office_type,
            office_features: office_features
          }.compact)

          collection(response, Speedy::Models::Location::OfficeResult)
        end

        alias find_offices find
        alias get_office get
        alias nearest_offices nearest
      end
    end
  end
end
