# frozen_string_literal: true

module Speedy
  module Models
    module Calculation
      class CalculationSender < Speedy::Model
        field :client_id, type: :integer
        field :private_person, type: :boolean
        field :address_location, type: Speedy::Models::Calculation::AddressLocation
        field :dropoff, type: :boolean
        field :dropoff_office_id, type: :integer
        field :dropoff_geo_pudo_id, type: :string
      end
    end
  end
end
