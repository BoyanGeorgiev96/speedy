# frozen_string_literal: true

module Speedy
  module Services
    module Shipments
      class Shipment < Speedy::ServiceResource
        include Speedy::Services::Shipments

        resource_path 'shipment'

        # POST /shipment
        def create(service:, content:, payment:, recipient:, sender: nil, **options)
          response = post(body: {
            service: service,
            content: content,
            payment: payment,
            sender: sender,
            recipient: recipient
          }.merge(options).compact)

          resource(response, Speedy::Models::Shipments::CreateShipmentResponse)
        end

        alias create_shipment create
      end
    end
  end
end
