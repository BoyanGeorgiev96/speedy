# frozen_string_literal: true

require 'csv'

module Speedy
  module Services
    module Location
      class State < Speedy::ServiceResource
        include Speedy::Services::Location

        resource_path 'location/state'

        # POST `/location/state/{id}`
        def get(id)
          response = post(id.to_s)

          resource(response, Speedy::Models::Location::State, key: :state)
        end

        # POST `/location/state`
        def find(country_id: nil, name: nil)
          response = post(body: {
            country_id: country_id,
            name: name
          }.compact)

          collection(response, Speedy::Models::Location::State)
        end

        # POST `/location/state/csv/{countryId}`
        def all(country_id:)
          response = post("csv/#{country_id}")
          rows = CSV.parse(response.body.to_s).filter_map do |row|
            next if row.compact.empty? || row.first.to_s == 'id'

            %i[id name name_en state_alpha country_id].zip(row).to_h
          end

          Speedy::Models::Location::State.collection(rows)
        end

        alias get_all_states all
      end
    end
  end
end
