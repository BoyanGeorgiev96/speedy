# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class ShipmentPrice < Speedy::Model
        field :amount, type: :float
        field :vat, type: :float
        field :total, type: :float
        field :currency, type: :string
        field :details
        field :amount_local, type: :float
        field :vat_local, type: :float
        field :total_local, type: :float
        field :currency_local, type: :string
        field :details_local
        field :currency_exchange_rate_unit, type: :integer
        field :currency_exchange_rate, type: :float
        field :return_amounts
      end
    end
  end
end
