# frozen_string_literal: true

require 'csv'

module Speedy
  module Services
    module Location
      class PointOfInterest < Speedy::ServiceResource
        resource_path 'location/poi'

        # POST `/location/poi/{id}`
        def get(id)
          response = post(id.to_s)

          resource(response, Speedy::Models::Location::PointOfInterest, key: :poi)
        end

        # POST `/location/poi`
        def find(site_id:, name: nil)
          response = post(body: { site_id: site_id, name: name }.compact)

          collection(response, Speedy::Models::Location::PointOfInterest)
        end

        # POST `/location/poi/csv/{countryId}`
        def all(country_id:)
          response = post("csv/#{country_id}")
          rows = CSV.parse(response.body.to_s).filter_map do |row|
            next if row.compact.empty? || row.first.to_s == 'id'

            %i[id site_id name name_en address address_en x y type type_en].zip(row).to_h
          end

          Speedy::Models::Location::PointOfInterest.collection(rows)
        end
      end
    end
  end
end
