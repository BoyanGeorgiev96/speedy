# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class ExternalCarrierParcelNumber < Speedy::Model
        field :external_carrier
        field :parcel_number, type: :string
      end
    end
  end
end
