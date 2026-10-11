# frozen_string_literal: true

module Speedy
  module Models
    module Print
      class LabelInfo < Speedy::Model
        field :parcel_id, type: :string
        field :hub_id, type: :integer
        field :office_id, type: :integer
        field :deadline_day, type: :integer
        field :deadline_month, type: :integer
        field :tour_id, type: :integer
        field :full_barcode, type: :string
        field :office_name, type: :string
        field :export_priority, type: :integer
      end
    end
  end
end
