# frozen_string_literal: true

module Speedy
  module Services
    module Validation
      class General < Speedy::ServiceResource
        resource_path 'validation'

        def phone(number:, extension: nil)
          response = post('phone', body: { number: number, ext: extension }.compact)

          resource(response, Speedy::Models::Validation::ValidationResponse)
        end

        def post_code(country_id:, post_code:, site_id: nil)
          response = post('postcode', body: {
            country_id: country_id, site_id: site_id, post_code: post_code
          }.compact)

          resource(response, Speedy::Models::Validation::ValidationResponse)
        end

        def shipment(service:, content:, payment:, recipient:, sender: nil, **options)
          response = post('shipment', body: {
            service: service,
            content: content,
            payment: payment,
            sender: sender,
            recipient: recipient
          }.merge(options).compact)

          resource(response, Speedy::Models::Validation::ValidationResponse)
        end
      end
    end
  end
end
