# frozen_string_literal: true

module Speedy
  module Models
    module Pickup
      class TermsResponse < Speedy::Model
        field :error, type: Speedy::Models::Error
        field :cutoffs, type: :array
      end
    end
  end
end
