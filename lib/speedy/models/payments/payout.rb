# frozen_string_literal: true

module Speedy
  module Models
    module Payments
      class Payout < Speedy::Model
        collection_key :payouts

        field :date, type: :date
        field :doc_id, type: :integer
        field :doc_type, type: :string
        field :payment_type, type: :string
        field :payee, type: :string
        field :currency, type: :string
        field :amount, type: :float
        field :details, type: :array, of: Speedy::Models::Payments::PayoutDetails
      end
    end
  end
end
