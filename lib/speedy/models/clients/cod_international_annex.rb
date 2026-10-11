# frozen_string_literal: true

module Speedy
  module Models
    module Clients
      class CODInternationalAnnex < Speedy::Model
        field :country_id, type: :integer
        field :country_name, type: :string
      end
    end
  end
end
