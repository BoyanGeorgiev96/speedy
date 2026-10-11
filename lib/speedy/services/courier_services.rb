# frozen_string_literal: true

module Speedy
  module Services
    class CourierServices < Speedy::ServiceResource
      resource_path 'services'

      # POST `/services`
      def all(date: nil)
        response = post(body: { date: date }.compact)

        collection(response, Speedy::Models::Services::CourierService)
      end

      # POST `/services/destination`
      def for_destination(sender:, recipient:, date: nil)
        response = post('destination', body: {
          date: date, sender: sender, recipient: recipient
        }.compact)

        collection(response, Speedy::Models::Services::ExtendedCourierService)
      end
    end
  end
end
