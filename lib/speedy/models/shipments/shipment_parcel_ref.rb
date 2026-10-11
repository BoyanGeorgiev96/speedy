# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class ShipmentParcelRef < Speedy::Model
        field :id, type: :string
        field :external_carrier_parcel_number, type: :string
        field :full_barcode, type: :string
      end
    end
  end
end
