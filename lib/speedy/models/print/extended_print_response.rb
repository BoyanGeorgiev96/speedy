# frozen_string_literal: true

module Speedy
  module Models
    module Print
      class ExtendedPrintResponse < Speedy::Model
        field :data, type: :string
        field :error, type: Speedy::Models::Error
        field :print_labels_info, type: :array, of: Speedy::Models::Print::LabelInfo
      end
    end
  end
end
