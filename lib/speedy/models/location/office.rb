# frozen_string_literal: true

module Speedy
  module Models
    module Location
      class Office < Speedy::Model
        collection_key :offices

        field :id, type: :integer
        field :name, type: :string
        field :name_en, type: :string
        field :site_id, type: :integer
        field :address, type: Speedy::Models::Common::Address
        field :working_time_from, type: :string
        field :working_time_to, type: :string
        field :working_time_half_from, type: :string
        field :working_time_half_to, type: :string
        field :working_time_day_off_from, type: :string
        field :working_time_day_off_to, type: :string
        field :same_day_departure_cutoff, type: :string
        field :same_day_departure_cutoff_half, type: :string
        field :same_day_departure_cutoff_day_off, type: :string
        field :max_parcel_dimensions, type: Speedy::Models::Shipments::ShipmentParcelSize
        field :max_parcel_weight, type: :float
        field :type, type: :string
        field :vendor, type: :integer
        field :nearby_office_id, type: :integer
        field :working_time_schedule, type: :array, of: Speedy::Models::Location::OfficeWorkingTimeSchedule
        field :valid_from, type: :string
        field :valid_to, type: :string
        field :cargo_types_allowed, type: :array
        field :pick_up_allowed, type: :boolean
        field :drop_off_allowed, type: :boolean
        field :routing_information, type: Speedy::Models::Location::RoutingInformation
        field :pallet_office, type: :boolean
        field :cash_payment_allowed, type: :boolean
        field :card_payment_allowed, type: :boolean
      end
    end
  end
end
