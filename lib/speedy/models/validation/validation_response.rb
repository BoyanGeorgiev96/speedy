# frozen_string_literal: true

module Speedy
  module Models
    module Validation
      class ValidationResponse < Speedy::Model
        field :error, type: Speedy::Models::Error
        field :valid, type: :boolean

        alias valid? valid
      end
    end
  end
end
