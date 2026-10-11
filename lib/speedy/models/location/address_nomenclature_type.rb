# frozen_string_literal: true

module Speedy
  module Models
    module Location
      class AddressNomenclatureType < Speedy::Model
        field :name, type: :string
        field :name_en, type: :string
      end
    end
  end
end
