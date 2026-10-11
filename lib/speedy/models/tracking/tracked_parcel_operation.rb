# frozen_string_literal: true

module Speedy
  module Models
    module Tracking
      class TrackedParcelOperation < Speedy::Model
        field :date_time, type: :string
        field :operation_code, type: :integer
        field :place, type: :string
        field :description, type: :string
        field :comment, type: :string
        field :exception_codes, type: :array
        field :return_shipment_id, type: :string
        field :redirect_shipment_id, type: :string
        field :consignee, type: :string
        field :pod_image_url, type: :string
        field :additional_info,
              type: Speedy::Models::Tracking::TrackedParcelOperationAdditionalInfo
      end
    end
  end
end
