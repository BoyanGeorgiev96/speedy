# frozen_string_literal: true

module Speedy
  module Models
    module Location
      class State < Speedy::Model
        collection_key :states

        field :id, type: :string
        field :name, type: :string
        field :name_en, type: :string
        field :state_alpha, type: :string
        field :country_id, type: :integer
      end
    end
  end
end
