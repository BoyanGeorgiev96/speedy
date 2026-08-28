# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class ShipmentRecipient < Speedy::Models::Shipments::ShipmentSender
        field :pickup_office_id, type: :integer
        field :pickup_geo_pudo_id, type: :string
        field :auto_select_nearest_office, type: :boolean
        field :auto_select_nearest_office_policy
      end
    end
  end
end
