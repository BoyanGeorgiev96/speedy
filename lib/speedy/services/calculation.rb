# frozen_string_literal: true

module Speedy
  module Services
    class Calculation < Speedy::ServiceResource
      resource_path 'calculate'

      # POST /calculate
      def calculate(recipient:, service:, content:, payment:, sender: nil, **options)
        response = post(body: {
          sender: sender,
          recipient: recipient,
          service: service,
          content: content,
          payment: payment
        }.merge(options).compact)

        collection(response, Speedy::Models::Calculation::CalculationResult)
      end
    end
  end
end
