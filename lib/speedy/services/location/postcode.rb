# frozen_string_literal: true

require 'csv'

module Speedy
  module Services
    module Location
      class Postcode < Speedy::ServiceResource
        resource_path 'location/postcode'

        # POST `/location/postcode/csv/{countryId}`
        def all(country_id:)
          response = post("csv/#{country_id}")
          rows = CSV.parse(response.body.to_s).filter_map do |row|
            next if row.compact.empty? || row.first.to_s == 'postcode'

            %i[postcode site_id].zip(row).to_h
          end

          Speedy::Models::Location::Postcode.collection(rows)
        end
      end
    end
  end
end
