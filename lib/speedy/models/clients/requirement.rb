# frozen_string_literal: true

module Speedy
  module Models
    module Clients
      class Requirement < Speedy::Model
        field :id, type: :integer
        field :text, type: :string
      end
    end
  end
end
