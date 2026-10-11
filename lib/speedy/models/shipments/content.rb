# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class Content < Speedy::Model
        field :parcels_count, type: :integer
        field :declared_weight, type: :float
        field :measured_weight, type: :float
        field :calculation_weight, type: :float
        field :contents, type: :string
        field :documents, type: :boolean
        field :palletized, type: :boolean
        field :parcels, type: :array, of: Speedy::Models::Shipments::Parcel
        field :pending_parcels, type: :boolean
        field :package, type: :string
      end
    end
  end
end
