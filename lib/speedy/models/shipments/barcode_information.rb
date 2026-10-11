# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class BarcodeInformation < Speedy::Model
        field :error, type: Speedy::Models::Error
        field :label_info, type: Speedy::Models::Print::LabelInfo
        field :primary_shipment, type: Speedy::Models::Shipments::PrimaryShipment
        field :primary_parcel_id, type: :string
        field :return_shipment_id, type: :string
        field :return_parcel_id, type: :string
        field :redirect_shipment_id, type: :string
        field :redirect_parcel_id, type: :string
        field :initial_shipment_id, type: :string
        field :initial_parcel_id, type: :string
      end
    end
  end
end
