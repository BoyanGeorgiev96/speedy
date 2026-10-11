# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class ShipmentDiscountCardId < Speedy::Model
        field :contract_id, type: :integer
        field :card_id, type: :integer
      end
    end
  end
end
