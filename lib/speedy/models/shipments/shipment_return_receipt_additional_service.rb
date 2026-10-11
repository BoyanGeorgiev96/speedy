# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class ShipmentReturnReceiptAdditionalService < Speedy::Model
        field :enabled, type: :boolean
        field :return_to_client_id, type: :integer
        field :return_to_office_id, type: :integer
        field :third_party_payer, type: :boolean
      end
    end
  end
end
