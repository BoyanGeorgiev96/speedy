# frozen_string_literal: true

module Speedy
  module Services
    module Location
      class Site < Speedy::ServiceResource
        include Speedy::Services::Location

        resource_path 'location/site'

        # POST /location/site
        def find(country_id: nil, name: nil, post_code: nil, type: nil, municipality: nil, region: nil)
          response = post(body: {
            country_id: country_id,
            name: name,
            post_code: post_code,
            type: type,
            municipality: municipality,
            region: region
          }.compact)

          collection(response, Speedy::Models::Location::Site)
        end

        # POST /location/site/{id}
        def get(id)
          response = post(id.to_s)

          resource(response, Speedy::Models::Location::GetSiteResponse)
        end

        # POST /location/site/all
        def all
          response = post('all')

          collection(response, Speedy::Models::Location::Site)
        end

        alias find_sites find
        alias get_site get
      end
    end
  end
end
