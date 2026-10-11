# frozen_string_literal: true

module Speedy
  module Services
    class Clients < Speedy::ServiceResource
      resource_path 'client'

      def get(id)
        response = post(id.to_s)
        resource(response, Speedy::Models::Clients::Client, key: :client)
      end

      def own_id
        response = post
        response.body[:client_id] || response.body['client_id'] || response.body['clientId']
      end

      def contract_clients
        response = post('contract')
        collection(response, Speedy::Models::Clients::Client)
      end

      def create_contact(**attributes)
        response = post('contact', body: attributes.compact)

        response.body[:client_id] || response.body['client_id'] || response.body['clientId']
      end

      def contact_by_external_id(id:, secret_key:)
        response = post("contact/external/#{id}", body: { secret_key: secret_key })
        resource(response, Speedy::Models::Clients::Client, key: :client)
      end

      def contract_info
        response = post('contract/info')
        resource(response, Speedy::Models::Clients::ContractInfo)
      end
    end
  end
end
