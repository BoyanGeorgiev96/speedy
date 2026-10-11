# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class ShipmentROPAdditionalServiceLine < Speedy::Model
        field :service_id, type: :integer
        field :parcels_count, type: :integer
      end
    end
  end
end
