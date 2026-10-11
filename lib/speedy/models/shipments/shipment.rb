# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class Shipment < Speedy::Model
        collection_key :shipments

        field :error, type: Speedy::Models::Error
        field :id, type: :string
        field :sender, type: Speedy::Models::Shipments::Sender
        field :recipient, type: Speedy::Models::Shipments::Recipient
        field :service, type: Speedy::Models::Shipments::ShipmentService
        field :content, type: Speedy::Models::Shipments::Content
        field :payment, type: Speedy::Models::Shipments::Payment
        field :shipment_note, type: :string
        field :ref1, type: :string
        field :ref2, type: :string
        field :price, type: Speedy::Models::Shipments::ShipmentPrice
        field :delivery, type: Speedy::Models::Shipments::ShipmentDelivery
        field :primary_shipment, type: Speedy::Models::Shipments::PrimaryShipment
        field :return_shipment_id, type: :string
        field :redirect_shipment_id, type: :string
        field :pending_shipment, type: :boolean
      end
    end
  end
end
