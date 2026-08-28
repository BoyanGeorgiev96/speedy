# frozen_string_literal: true

module Speedy
  module Models
    module Calculation
      class CalculationContent < Speedy::Model
        field :parcels_count, type: :integer
        field :total_weight, type: :float
        field :documents, type: :boolean
        field :palletized, type: :boolean
        field :parcels, type: :array, of: Speedy::Models::Shipments::ShipmentParcel
      end
    end
  end
end
