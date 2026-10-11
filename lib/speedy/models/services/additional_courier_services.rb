# frozen_string_literal: true

module Speedy
  module Models
    module Services
      class AdditionalCourierServices < Speedy::Model
        field :cod, type: AdditionalCourierService
        field :obpd, type: AdditionalCourierService
        field :declared_value, type: AdditionalCourierService
        field :fixed_time_delivery, type: AdditionalCourierService
        field :special_delivery, type: AdditionalCourierService
        field :delivery_to_floor, type: AdditionalCourierService
        field :rod, type: AdditionalCourierService
        field :return_receipt, type: AdditionalCourierService
        field :swap, type: AdditionalCourierService
        field :rop, type: AdditionalCourierService
        field :return_voucher, type: AdditionalCourierService
      end
    end
  end
end
