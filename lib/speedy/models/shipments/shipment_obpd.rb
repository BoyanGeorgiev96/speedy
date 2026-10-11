# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class ShipmentOBPD < Speedy::Model
        field :option, type: :string
        field :return_shipment_service_id, type: :integer
        field :return_shipment_payer, type: :string
      end
    end
  end
end
