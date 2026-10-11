# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class ShipmentParcelSize < Speedy::Model
        field :width, type: :integer
        field :height, type: :integer
        field :depth, type: :integer
      end
    end
  end
end
