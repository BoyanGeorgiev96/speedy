# frozen_string_literal: true

module Speedy
  module Models
    module Tracking
      class ExternalCarrierParcelNumberDetails < Speedy::Model
        field :external_carrier_id, type: :integer
        field :external_carrier_name, type: :string
        field :track_and_trace_url, type: :string
      end
    end
  end
end
