# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class ShipmentDelivery < Speedy::Model
        field :deadline, type: :string
        field :delivery_date_time, type: :string
        field :consignee, type: :string
        field :delivery_note, type: :string
      end
    end
  end
end
