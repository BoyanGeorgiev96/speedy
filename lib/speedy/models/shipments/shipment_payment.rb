# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class ShipmentPayment < Speedy::Model
        field :courier_service_payer, type: :string
        field :declared_value_payer, type: :string
        field :package_payer, type: :string
        field :third_party_client_id, type: :integer
        field :discount_card_id, type: Speedy::Models::Shipments::ShipmentDiscountCardId
        field :sender_bank_account, type: Speedy::Models::Shipments::BankAccount
        field :administrative_fee, type: :boolean
      end
    end
  end
end
