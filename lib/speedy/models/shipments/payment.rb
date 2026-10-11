# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class Payment < Speedy::Model
        field :courier_service_payer, type: :string
        field :declared_value_payer, type: :string
        field :package_payer, type: :string
        field :third_party_client_id, type: :integer
        field :discount_card_id, type: Speedy::Models::Shipments::ShipmentDiscountCardId
        field :cod_payment, type: Speedy::Models::Shipments::CODPayment
      end
    end
  end
end
