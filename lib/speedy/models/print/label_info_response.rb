# frozen_string_literal: true

module Speedy
  module Models
    module Print
      class LabelInfoResponse < Speedy::Model
        field :print_labels_info, type: :array, of: Speedy::Models::Print::LabelInfo
        field :error, type: Speedy::Models::Error
      end
    end
  end
end
