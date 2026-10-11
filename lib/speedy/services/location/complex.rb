# frozen_string_literal: true

require 'csv'

module Speedy
  module Services
    module Location
      class Complex < Speedy::ServiceResource
        resource_path 'location/complex'

        # POST `/location/complex/{id}`
        def get(id)
          response = post(id.to_s)

          resource(response, Speedy::Models::Location::Complex, key: :complex)
        end

        # POST `/location/complex`
        def find(site_id:, name: nil, type: nil)
          response = post(body: { site_id: site_id, name: name, type: type }.compact)

          collection(response, Speedy::Models::Location::Complex)
        end

        # POST `/location/complex/csv/{countryId}`
        def all(country_id:)
          response = post("csv/#{country_id}")
          rows = CSV.parse(response.body.to_s).filter_map do |row|
            next if row.compact.empty? || row.first.to_s == 'id'

            %i[id site_id type type_en name name_en actual_id].zip(row).to_h
          end

          Speedy::Models::Location::Complex.collection(rows)
        end
      end
    end
  end
end
