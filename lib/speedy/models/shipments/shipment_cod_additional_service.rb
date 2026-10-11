# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class ShipmentCODAdditionalService < Speedy::Model
        field :amount, type: :float
        field :currency_code, type: :string
        field :payout_to_third_party, type: :boolean
        field :payout_to_logged_client, type: :boolean
        field :processing_type, type: :string
        field :include_shipping_price, type: :boolean
        field :card_payment_forbidden, type: :boolean
        field :fiscal_receipt_items,
              type: :array,
              of: Speedy::Models::Shipments::ShipmentCODFiscalReceiptItem
      end
    end
  end
end
