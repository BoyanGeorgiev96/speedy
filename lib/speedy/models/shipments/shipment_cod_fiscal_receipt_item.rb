# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class ShipmentCODFiscalReceiptItem < Speedy::Model
        field :description, type: :string
        field :vat_group, type: :string
        field :amount, type: :float
        field :amount_with_vat, type: :float
      end
    end
  end
end
