# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class Parcel < Speedy::Model
        field :id, type: :string
        field :seq_no, type: :integer
        field :package_unique_number, type: :integer
        field :declared_size, type: Speedy::Models::Shipments::ShipmentParcelSize
        field :measured_size, type: Speedy::Models::Shipments::ShipmentParcelSize
        field :calculation_size, type: Speedy::Models::Shipments::ShipmentParcelSize
        field :declared_weight, type: :float
        field :measured_weight, type: :float
        field :calculation_weight, type: :float
        field :external_carrier_parcel_numbers, type: :array
        field :base_type, type: :string
        field :size, type: :string
      end
    end
  end
end
