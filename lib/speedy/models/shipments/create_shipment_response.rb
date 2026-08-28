# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class CreateShipmentResponse < Speedy::Model
        field :id, type: :string
        field :parcels, type: :array, of: Speedy::Models::Shipments::CreatedShipmentParcel
        field :pickup_date, type: :string
        field :price, type: Speedy::Models::Shipments::ShipmentPrice
        field :delivery_deadline, type: :string
        field :error, type: Speedy::Models::Error
      end
    end
  end
end
