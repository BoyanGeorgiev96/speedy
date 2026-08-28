# frozen_string_literal: true

module Speedy
  module Models
    module Location
      class GetOfficeResponse < Speedy::Model
        field :office, type: Speedy::Models::Location::Office
        field :error, type: Speedy::Models::Error
      end
    end
  end
end
