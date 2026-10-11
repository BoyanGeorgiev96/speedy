# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class MoneyTransferPremium < Speedy::Model
        field :amount, type: :float
        field :amount_local, type: :float
        field :payer, type: :string
      end
    end
  end
end
