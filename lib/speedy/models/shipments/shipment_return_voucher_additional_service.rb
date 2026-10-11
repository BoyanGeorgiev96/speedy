# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class ShipmentReturnVoucherAdditionalService < Speedy::Model
        field :service_id, type: :integer
        field :payer, type: :string
        field :validity_period, type: :integer
        field :external_return_voucher_id, type: :string
      end
    end
  end
end
