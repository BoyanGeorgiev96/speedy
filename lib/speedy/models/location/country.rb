# frozen_string_literal: true

module Speedy
  module Models
    module Location
      class Country < Speedy::Model
        collection_key :countries

        field :id, type: :integer
        field :name, type: :string
        field :name_en, type: :string
        field :iso_alpha2, type: :string
        field :iso_alpha3, type: :string
        field :currency_code, type: :string
        field :require_state, type: :boolean
        field :address_type, type: :integer
        field :default_office_id, type: :integer
        field :site_nomen, type: :integer
        field :street_types, type: :array, of: Speedy::Models::Location::AddressNomenclatureType
        field :complex_types, type: :array, of: Speedy::Models::Location::AddressNomenclatureType
        field :post_code_formats, type: :array
      end
    end
  end
end
