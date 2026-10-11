# frozen_string_literal: true

module Speedy
  module Models
    module Location
      class GetSiteResponse < Speedy::Model
        field :site, type: Speedy::Models::Location::Site
        field :error, type: Speedy::Models::Error
      end
    end
  end
end
