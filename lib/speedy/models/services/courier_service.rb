# frozen_string_literal: true

module Speedy
  module Models
    module Services
      class CourierService < Speedy::Model
        collection_key :services

        field :id, type: :integer
        field :name, type: :string
        field :name_en, type: :string
        field :additional_services, type: Speedy::Models::Services::AdditionalCourierServices
        field :cargo_type, type: :string
        field :require_parcel_weight, type: :boolean
        field :require_parcel_size, type: :boolean
      end
    end
  end
end
