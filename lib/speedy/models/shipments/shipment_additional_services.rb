# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class ShipmentAdditionalServices < Speedy::Model
        field :cod, type: Speedy::Models::Shipments::ShipmentCODAdditionalService
        field :declared_value, type: Speedy::Models::Shipments::ShipmentDeclaredValueAdditionalService
        field :fixed_time_delivery, type: :integer
        field :returns, type: Speedy::Models::Shipments::ShipmentReturnAdditionalServices
        field :special_delivery_id, type: :integer
        field :delivery_to_floor, type: :integer
        field :obpd, type: Speedy::Models::Shipments::ShipmentOBPD
      end
    end
  end
end
