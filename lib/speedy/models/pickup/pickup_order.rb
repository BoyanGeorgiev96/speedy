# frozen_string_literal: true

module Speedy
  module Models
    module Pickup
      class PickupOrder < Speedy::Model
        collection_key :orders

        field :id, type: :integer
        field :shipment_ids, type: :array
        field :pickup_period_from, type: :string
        field :pickup_period_to, type: :string
      end
    end
  end
end
