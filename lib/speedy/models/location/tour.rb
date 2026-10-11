# frozen_string_literal: true

module Speedy
  module Models
    module Location
      class Tour < Speedy::Model
        field :number, type: :integer
        field :office_id, type: :integer
        field :ramp, type: :string
        field :cell, type: :string
      end
    end
  end
end
