# frozen_string_literal: true

module Speedy
  module Models
    module Tracking
      class TrackedParcel < Speedy::Model
        collection_key :parcels

        field :parcel_id, type: :string
        field :external_carrier_parcel_numbers, type: :array
        field :operations, type: :array, of: Speedy::Models::Tracking::TrackedParcelOperation
        field :error, type: Speedy::Models::Error
        field :ref, type: :string
        field :track_phase, type: :string
        field :external_carrier_parcel_numbers_details,
              type: :hash,
              of: Speedy::Models::Tracking::ExternalCarrierParcelNumberDetails
      end
    end
  end
end
