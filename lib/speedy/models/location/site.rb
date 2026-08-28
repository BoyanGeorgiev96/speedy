# frozen_string_literal: true

module Speedy
  module Models
    module Location
      class Site < Speedy::Model
        collection_key :sites

        field :id, type: :integer
        field :country_id, type: :integer
        field :main_site_id, type: :integer
        field :type, type: :string
        field :type_en, type: :string
        field :name, type: :string
        field :name_en, type: :string
        field :municipality, type: :string
        field :municipality_en, type: :string
        field :region, type: :string
        field :region_en, type: :string
        field :post_code, type: :string
        field :serving_days, type: :string
        field :address_nomenclature, type: :integer
        field :x, type: :float
        field :y, type: :float
        field :serving_office_id, type: :integer
        field :serving_hub_office_id, type: :integer
      end
    end
  end
end
