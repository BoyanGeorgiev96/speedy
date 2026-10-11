# frozen_string_literal: true

module Speedy
  module Models
    module Location
      class PointOfInterest < Speedy::Model
        collection_key :pois

        field :id, type: :integer
        field :site_id, type: :integer
        field :type, type: :string
        field :type_en, type: :string
        field :name, type: :string
        field :name_en, type: :string
        field :address, type: :string
        field :address_en, type: :string
        field :x, type: :float
        field :y, type: :float
      end
    end
  end
end
