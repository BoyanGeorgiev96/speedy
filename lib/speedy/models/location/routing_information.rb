# frozen_string_literal: true

module Speedy
  module Models
    module Location
      class RoutingInformation < Speedy::Model
        field :tour, type: Speedy::Models::Location::Tour
        field :office_id, type: :integer
        field :hub_id, type: :integer
        field :priority, type: :integer
      end
    end
  end
end
