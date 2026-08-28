# frozen_string_literal: true

module Speedy
  module Models
    module Calculation
      class AddressLocation < Speedy::Model
        field :country_id, type: :integer
        field :state_id, type: :string
        field :site_id, type: :integer
        field :site_type, type: :string
        field :site_name, type: :string
        field :post_code, type: :string
      end
    end
  end
end
