# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class ShipmentElectronicReturnReceiptAdditionalService < Speedy::Model
        field :recipient_emails, type: :array
        field :third_party_payer, type: :boolean
        field :return_to_client_id, type: :integer
        field :return_to_office_id, type: :integer
      end
    end
  end
end
