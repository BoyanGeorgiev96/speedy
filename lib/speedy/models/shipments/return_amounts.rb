# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class ReturnAmounts < Speedy::Model
        field :money_transfer, type: Speedy::Models::Shipments::MoneyTransferPremium
      end
    end
  end
end
