# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class ShipmentParcel < Speedy::Model
        field :id, type: :string
        field :seq_no, type: :integer
        field :package_unique_number, type: :integer
        field :size, type: Speedy::Models::Shipments::ShipmentParcelSize
        field :weight, type: :float
        field :pickup_external_carrier_parcel_number,
              type: Speedy::Models::Shipments::ExternalCarrierParcelNumber
        field :delivery_external_carrier_parcel_number,
              type: Speedy::Models::Shipments::ExternalCarrierParcelNumber
        field :ref1, type: :string
        field :ref2, type: :string
        field :goods, type: :array, of: Speedy::Models::Shipments::GoodsItem
        field :print_additional_barcode, type: Speedy::Models::Print::ParcelToPrintAdditionalBarcode
      end
    end
  end
end
