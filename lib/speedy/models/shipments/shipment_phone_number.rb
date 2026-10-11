# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class ShipmentPhoneNumber < Speedy::Model
        field :number, type: :string
        field :extension, type: :string
      end
    end
  end
end
