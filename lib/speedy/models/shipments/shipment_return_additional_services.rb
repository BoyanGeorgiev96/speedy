# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class ShipmentReturnAdditionalServices < Speedy::Model
        field :rod, type: Speedy::Models::Shipments::ShipmentRODAdditionalService
        field :return_receipt,
              type: Speedy::Models::Shipments::ShipmentReturnReceiptAdditionalService
        field :electronic_return_receipt,
              type: Speedy::Models::Shipments::ShipmentElectronicReturnReceiptAdditionalService
        field :swap, type: Speedy::Models::Shipments::ShipmentSWAPAdditionalService
        field :rop, type: Speedy::Models::Shipments::ShipmentROPAdditionalService
        field :return_voucher,
              type: Speedy::Models::Shipments::ShipmentReturnVoucherAdditionalService
        field :send_back_client_id, type: :integer
      end
    end
  end
end
