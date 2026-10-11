# frozen_string_literal: true

module Speedy
  module Models
    module Clients
      class ContractInfo < Speedy::Model
        field :error, type: Speedy::Models::Error
        field :id, type: :integer
        field :special_delivery_requirements,
              type: Speedy::Models::Clients::SpecialDeliveryRequirements
        field :cod, type: Speedy::Models::Clients::CODContractInfo
        field :administrative_fee_allowed, type: :boolean
      end
    end
  end
end
