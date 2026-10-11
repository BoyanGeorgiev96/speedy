# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class ShipmentDeclaredValueAdditionalService < Speedy::Model
        field :amount, type: :float
        field :fragile, type: :boolean
        field :ignore_if_not_applicable, type: :boolean
      end
    end
  end
end
