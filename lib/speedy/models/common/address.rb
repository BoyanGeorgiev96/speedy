# frozen_string_literal: true

module Speedy
  module Models
    module Common
      class Address < Speedy::Model
        field :country_id, type: :integer
        field :state_id, type: :string
        field :site_id, type: :integer
        field :site_type, type: :string
        field :site_name, type: :string
        field :post_code, type: :string
        field :street_id, type: :integer
        field :street_type, type: :string
        field :street_name, type: :string
        field :street_no, type: :string
        field :complex_id, type: :integer
        field :complex_type, type: :string
        field :complex_name, type: :string
        field :block_no, type: :string
        field :entrance_no, type: :string
        field :floor_no, type: :string
        field :apartment_no, type: :string
        field :poi_id, type: :integer
        field :address_note, type: :string
        field :address_line1, type: :string
        field :address_line2, type: :string
        field :x, type: :float
        field :y, type: :float
        field :full_address_string, type: :string
        field :site_address_string, type: :string
        field :local_address_string, type: :string
      end
    end
  end
end
