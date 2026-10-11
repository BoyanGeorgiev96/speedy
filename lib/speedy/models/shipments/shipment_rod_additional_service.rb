# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class ShipmentRODAdditionalService < Speedy::Model
        field :enabled, type: :boolean
        field :comment, type: :string
        field :return_to_client_id, type: :integer
        field :return_to_office_id, type: :integer
        field :third_party_payer, type: :boolean
      end
    end
  end
end
