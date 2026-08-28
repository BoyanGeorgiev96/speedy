# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class ShipmentParcel < Speedy::Model
        field :id, type: :string
        field :seq_no, type: :integer
        field :package_unique_number, type: :integer
        field :size
        field :weight, type: :float
        field :pickup_external_carrier_parcel_number
        field :delivery_external_carrier_parcel_number
        field :ref1, type: :string
        field :ref2, type: :string
        field :goods, type: :array
        field :print_additional_barcode
      end
    end
  end
end
