# frozen_string_literal: true

module Speedy
  module Models
    module Clients
      class SpecialDeliveryRequirements < Speedy::Model
        field :required_for_all_shipments, type: :boolean
        field :requirements, type: :array, of: Speedy::Models::Clients::Requirement
      end
    end
  end
end
