# frozen_string_literal: true

module Speedy
  module Services
    class Pickup < Speedy::ServiceResource
      resource_path 'pickup'

      # POST `/pickup`
      def create(pickup_date_time:, pickup_scope: nil, explicit_shipment_id_list: nil,
                 visit_end_time: nil, contact_name: nil, phone_number: nil,
                 auto_adjust_pickup_date: nil)
        response = post(body: {
          pickup_date_time: pickup_date_time,
          pickup_scope: pickup_scope,
          explicit_shipment_id_list: explicit_shipment_id_list,
          visit_end_time: visit_end_time,
          contact_name: contact_name,
          phone_number: phone_number,
          auto_adjust_pickup_date: auto_adjust_pickup_date
        }.compact)

        collection(response, Speedy::Models::Pickup::PickupOrder)
      end

      # POST `/pickup/terms`
      def terms(service_id:, starting_date: nil, sender: nil, sender_has_payment: nil)
        response = post('terms', body: {
          service_id: service_id,
          starting_date: starting_date,
          sender: sender,
          sender_has_payment: sender_has_payment
        }.compact)

        resource(response, Speedy::Models::Pickup::TermsResponse)
      end
    end
  end
end
