# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class GoodsItem < Speedy::Model
        field :description, type: :string
        field :hs_code, type: :string
        field :quantity, type: :integer
        field :value_per_item, type: :float
        field :weight_per_item, type: :float
        field :origin_country_code, type: :string
      end
    end
  end
end
