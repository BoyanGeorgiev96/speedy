# frozen_string_literal: true

module Speedy
  module Models
    module Tracking
      class TrackedParcelOperationAdditionalInfo < Speedy::Model
        field :office_url, type: :string
        field :recipient,
              type: Speedy::Models::Tracking::TrackedParcelOperationAdditionalInfoRecipient
        field :unsuccessful_delivery_sticker_image_url, type: :string
        field :pickup_office_type, type: :string
        field :geo_pudo_id, type: :string
        field :predict, type: Speedy::Models::Tracking::TrackedParcelOperationAdditionalInfoPredict
      end
    end
  end
end
