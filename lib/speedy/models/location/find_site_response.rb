# frozen_string_literal: true

module Speedy
  module Models
    module Location
      class FindSiteResponse < Speedy::Model
        field :sites, type: :array, of: Speedy::Models::Location::Site
        field :error, type: Speedy::Models::Error
      end
    end
  end
end
