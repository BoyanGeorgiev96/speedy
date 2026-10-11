# frozen_string_literal: true

module Speedy
  module Models
    module Location
      class Street < Speedy::Model
        collection_key :streets

        field :id, type: :integer
        field :actual_id, type: :integer
        field :site_id, type: :integer
        field :type, type: :string
        field :type_en, type: :string
        field :name, type: :string
        field :name_en, type: :string
        field :actual_type, type: :string
        field :actual_type_en, type: :string
        field :actual_name, type: :string
        field :actual_name_en, type: :string
      end
    end
  end
end
