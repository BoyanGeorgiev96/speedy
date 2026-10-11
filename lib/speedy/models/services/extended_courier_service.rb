# frozen_string_literal: true

module Speedy
  module Models
    module Services
      class ExtendedCourierService < CourierService
        collection_key :services

        field :deadline, type: :string
      end
    end
  end
end
