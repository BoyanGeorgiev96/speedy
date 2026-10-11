# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class ShipmentROPAdditionalService < Speedy::Model
        field :pallets, type: :array, of: Speedy::Models::Shipments::ShipmentROPAdditionalServiceLine
        field :third_party_payer, type: :boolean
      end
    end
  end
end
