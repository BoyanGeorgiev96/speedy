# frozen_string_literal: true

module Speedy
  module Models
    class Response < Speedy::Model
      field :error, type: Speedy::Models::Error

      def success?
        !error?
      end
    end
  end
end
