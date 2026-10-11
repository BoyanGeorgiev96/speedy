# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class PrimaryShipment < Speedy::Model
        field :id, type: :string
        field :type, type: :string
      end
    end
  end
end
