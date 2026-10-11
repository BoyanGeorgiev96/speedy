# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class BankAccount < Speedy::Model
        field :iban, type: :string
        field :account_holder, type: :string
      end
    end
  end
end
