# frozen_string_literal: true

module Speedy
  module Models
    module Shipments
      class ShipmentService < Speedy::Model
        field :pickup_date, type: :string
        field :service_id, type: :integer
        field :additional_services
        field :deferred_days, type: :integer
        field :saturday_delivery, type: :boolean
        field :auto_adjust_pickup_date, type: :boolean
        field :delivery_limit_violation_auto_adjustment
      end
    end
  end
end
