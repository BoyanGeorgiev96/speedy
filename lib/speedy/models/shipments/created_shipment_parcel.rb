# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class CreatedShipmentParcel < Speedy::Model
        field :id, type: :string
        field :seq_no, type: :integer
        field :external_carrier_id, type: :integer
        field :external_carrier_parcel_number, type: :string
      end
    end
  end
end
