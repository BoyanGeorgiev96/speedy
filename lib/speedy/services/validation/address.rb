# frozen_string_literal: true

module Speedy
  module Services
    module Validation
      class Address < Speedy::ServiceResource
        include Speedy::Services::Validation

        resource_path 'validation/address'

        # POST /validation/address
        def validate_address(address)
          response = post(body: { address: address_to_hash(address) })

          resource(response, Speedy::Models::Validation::ValidationResponse)
        end

        private

        def address_to_hash(address)
          return address.to_h if address.is_a?(Speedy::Models::Shipments::ShipmentAddress)

          Speedy::Models::Shipments::ShipmentAddress.new(address).to_h
        end
      end
    end
  end
end
