# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class ShipmentContent < Speedy::Model
        field :parcels_count, type: :integer
        field :total_weight, type: :float
        field :contents, type: :string
        field :package, type: :string
        field :documents, type: :boolean
        field :palletized, type: :boolean
        field :parcels, type: :array, of: Speedy::Models::Shipments::ShipmentParcel
        field :pending_parcels, type: :boolean
        field :excise_goods, type: :boolean
        field :lq, type: :boolean
        field :uit_code, type: :string
        field :goods_value, type: :float
        field :goods_value_currency_code, type: :string
        field :print_additional_barcode
      end
    end
  end
end
