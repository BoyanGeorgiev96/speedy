# frozen_string_literal: true

module Speedy
  module Services
    class Payments < Speedy::ServiceResource
      resource_path 'payments'

      def payouts(from_date:, to_date:, include_details: nil)
        response = post(body: {
          from_date: from_date,
          to_date: to_date,
          include_details: include_details
        }.compact)

        collection(response, Speedy::Models::Payments::Payout)
      end
    end
  end
end
