# frozen_string_literal: true

module Speedy
  module Models
    module Tracking
      class BulkTrackingDataFile < Speedy::Model
        collection_key :files

        field :id, type: :integer
        field :url, type: :string
      end
    end
  end
end
