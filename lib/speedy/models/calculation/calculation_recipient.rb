# frozen_string_literal: true

module Speedy
  module Models
    module Calculation
      class CalculationRecipient < Speedy::Model
        field :client_id, type: :integer
        field :private_person, type: :boolean
        field :address_location, type: Speedy::Models::Calculation::AddressLocation
        field :pickup_office_id, type: :integer
        field :pickup_geo_pudo_id, type: :string
      end
    end
  end
end
