# frozen_string_literal: true

module Speedy
  module Models
    module Location
      class OfficeWorkingTimeSchedule < Speedy::Model
        field :date, type: :string
        field :working_time_from, type: :string
        field :working_time_to, type: :string
        field :same_day_departure_cutoff, type: :string
        field :standard_schedule, type: :boolean
      end
    end
  end
end
