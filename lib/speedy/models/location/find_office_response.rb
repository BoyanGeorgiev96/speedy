# frozen_string_literal: true

module Speedy
  module Models
    module Location
      class FindOfficeResponse < Speedy::Model
        field :offices, type: :array, of: Speedy::Models::Location::Office
        field :error, type: Speedy::Models::Error
      end
    end
  end
end
