# frozen_string_literal: true

require 'csv'

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

        # POST /location/site/csv/{countryId}
        def all(country_id:)
          response = post("csv/#{country_id}")

          Speedy::Models::Location::Site.collection(csv_sites(response.body))
        end

        alias find_sites find
        alias get_site get

        CSV_FIELDS = %i[
          id
          country_id
          main_site_id
          type
          type_en
          name
          name_en
          municipality
          municipality_en
          region
          region_en
          post_code
          address_nomenclature
          x
          y
          serving_days
          serving_office_id
          serving_hub_office_id
        ].freeze

        private

        def csv_sites(body)
          CSV.parse(body.to_s).filter_map do |row|
            next if row.compact.empty? || row.first.to_s == 'id'

            CSV_FIELDS.zip(row).to_h
          end
        end
      end
    end
  end
end
