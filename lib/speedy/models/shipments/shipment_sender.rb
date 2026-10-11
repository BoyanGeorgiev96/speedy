# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class ShipmentSender < Speedy::Model
        field :client_id, type: :integer
        field :phone1, type: Speedy::Models::Shipments::ShipmentPhoneNumber
        field :phone2, type: Speedy::Models::Shipments::ShipmentPhoneNumber
        field :phone3, type: Speedy::Models::Shipments::ShipmentPhoneNumber
        field :client_name, type: :string
        field :contact_name, type: :string
        field :object_name, type: :string
        field :email, type: :string
        field :private_person, type: :boolean
        field :address, type: Speedy::Models::Shipments::ShipmentAddress
        field :dropoff_office_id, type: :integer
        field :dropoff_geo_pudo_id, type: :string
        field :dropoff, type: :boolean
      end
    end
  end
end
