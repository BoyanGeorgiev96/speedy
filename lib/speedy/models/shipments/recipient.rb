# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class Recipient < Speedy::Model
        field :client_id, type: :integer
        field :client_name, type: :string
        field :object_name, type: :string
        field :contact_name, type: :string
        field :address, type: Speedy::Models::Common::Address
        field :email, type: :string
        field :private_person, type: :boolean
        field :phones, type: :array, of: Speedy::Models::Shipments::ShipmentPhoneNumber
        field :external_contact_id, type: :string
        field :pickup_office_id, type: :integer
        field :pickup_geo_pudo_id, type: :string
      end
    end
  end
end
