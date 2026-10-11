# frozen_string_literal: true

module Speedy
  module Models
    module Payments
      class PayoutDetails < Speedy::Model
        field :line_no, type: :integer
        field :shipment_id, type: :string
        field :pickup_date, type: :date
        field :primary_shipment_pickup_date, type: :date
        field :delivery_date, type: :date
        field :sender, type: :string
        field :recipient, type: :string
        field :note, type: :string
        field :ref1, type: :string
        field :ref2, type: :string
        field :currency, type: :string
        field :order, type: :integer
        field :amount, type: :float
      end
    end
  end
end
