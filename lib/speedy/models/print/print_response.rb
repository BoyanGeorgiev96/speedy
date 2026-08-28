# frozen_string_literal: true

module Speedy
  module Models
    module Print
      class PrintResponse < Speedy::Model
        field :data, type: :string
        field :error, type: Speedy::Models::Error
      end
    end
  end
end
