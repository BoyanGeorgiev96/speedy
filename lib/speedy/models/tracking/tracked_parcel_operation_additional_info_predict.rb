# frozen_string_literal: true

module Speedy
  module Models
    module Tracking
      class TrackedParcelOperationAdditionalInfoPredict < Speedy::Model
        field :predicted_visit_date_time_from, type: :string
        field :predicted_visit_date_time_to, type: :string
        field :included_delay_in_minutes, type: :integer
        field :canceled, type: :boolean
      end
    end
  end
end
