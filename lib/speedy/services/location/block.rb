# frozen_string_literal: true

require 'csv'

module Speedy
  module Services
    module Location
      class Block < Speedy::ServiceResource
        resource_path 'location/block'

        # POST `/location/block`
        def find(site_id:, name: nil)
          response = post(body: { site_id: site_id, name: name }.compact)

          collection(response, Speedy::Models::Location::Block)
        end

        # POST `/location/block/csv/{countryId}`
        def all(country_id:)
          response = post("csv/#{country_id}")
          rows = CSV.parse(response.body.to_s).filter_map do |row|
            next if row.compact.empty? || row.first.to_s == 'siteId'

            %i[site_id name name_en].zip(row).to_h
          end

          Speedy::Models::Location::Block.collection(rows)
        end
      end
    end
  end
end
