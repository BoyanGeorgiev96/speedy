# frozen_string_literal: true

module Speedy
  module Services
    module Location
      class State < Speedy::ServiceResource
        include Speedy::Services::Location

        resource_path 'location/state'

        # POST /location/state
        def all(country_id: nil)
          response = post(body: {
            country_id: country_id
          }.compact)

          collection(response, Speedy::Models::Location::State)
        end

        alias get_all_states all
      end
    end
  end
end
