# frozen_string_literal: true

module Speedy
  module Models
    module Location
      class OfficeResult < Office
        collection_key :offices

        field :distance, type: :integer
      end
    end
  end
end
