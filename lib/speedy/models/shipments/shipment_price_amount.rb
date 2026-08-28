# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class ShipmentPriceAmount < Speedy::Model
        field :amount, type: :float
        field :percent, type: :float
        field :vat_percent, type: :float
      end
    end
  end
end
