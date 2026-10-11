# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class ShipmentSWAPAdditionalService < Speedy::Model
        field :service_id, type: :integer
        field :parcels_count, type: :integer
        field :declared_value, type: :float
        field :fragile, type: :boolean
        field :return_to_client_id, type: :integer
        field :return_to_office_id, type: :integer
        field :third_party_payer, type: :boolean
      end
    end
  end
end
