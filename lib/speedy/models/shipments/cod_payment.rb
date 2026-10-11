# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class CODPayment < Speedy::Model
        field :date, type: :string
        field :total_payed_out_amount, type: :float
      end
    end
  end
end
