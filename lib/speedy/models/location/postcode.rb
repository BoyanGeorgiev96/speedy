# frozen_string_literal: true

module Speedy
  module Models
    module Location
      class Postcode < Speedy::Model
        field :postcode, type: :string
        field :site_id, type: :integer
      end
    end
  end
end
