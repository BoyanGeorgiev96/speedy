# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class ShipmentParcelNumber < Speedy::Model
        field :id, type: :string
        field :seq_no, type: :integer
      end
    end
  end
end
