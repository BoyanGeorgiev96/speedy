# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class SecondaryShipment < Speedy::Model
        collection_key :shipments

        field :id, type: :string
        field :type, type: :string
        field :parcels, type: :array, of: Speedy::Models::Shipments::ShipmentParcelNumber
        field :pickup_date, type: :date
        field :service_id, type: :integer
        field :has_scans, type: :boolean
      end
    end
  end
end
