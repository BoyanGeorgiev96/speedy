# frozen_string_literal: true

module Speedy
  module Models
    module Tracking
      class TrackedParcelOperationAdditionalInfoRecipient < Speedy::Model
        field :country_id, type: :integer
        field :phone1, type: :string
        field :phone2, type: :string
        field :phone3, type: :string
      end
    end
  end
end
