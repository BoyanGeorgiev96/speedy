# frozen_string_literal: true

module Speedy
  module Models
    module Print
      class ParcelToPrintAdditionalBarcode < Speedy::Model
        field :value_type, type: :string
        field :value, type: :string
        field :label, type: :string
        field :format, type: :string
      end
    end
  end
end
