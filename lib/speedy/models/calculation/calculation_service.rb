# frozen_string_literal: true

module Speedy
  module Models
    module Calculation
      class CalculationService < Speedy::Model
        field :pickup_date, type: :string
        field :auto_adjust_pickup_date, type: :boolean
        field :service_ids, type: :array
        field :additional_services
        field :deferred_days, type: :integer
        field :saturday_delivery, type: :boolean
      end
    end
  end
end
