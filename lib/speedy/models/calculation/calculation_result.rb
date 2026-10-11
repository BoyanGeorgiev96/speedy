# frozen_string_literal: true

module Speedy
  module Models
    module Calculation
      class CalculationResult < Speedy::Model
        collection_key :calculations

        field :service_id, type: :integer
        field :price, type: Speedy::Models::Shipments::ShipmentPrice
        field :pickup_date, type: :string
        field :delivery_deadline, type: :string
        field :delivery_deadline_work_day_type, type: :string
        field :additional_services, type: Speedy::Models::Shipments::ShipmentAdditionalServices
        field :error, type: Speedy::Models::Error
      end
    end
  end
end
