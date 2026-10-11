# frozen_string_literal: true

module Speedy
  module Models
    module Location
      class Block < Speedy::Model
        collection_key :blocks

        field :site_id, type: :integer
        field :name, type: :string
        field :name_en, type: :string
      end
    end
  end
end
