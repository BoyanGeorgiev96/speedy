# frozen_string_literal: true

module Speedy
  module Services
    class Tracking < Speedy::ServiceResource
      resource_path 'track'

      # POST `/track`
      def track(parcels:, last_operation_only: nil)
        response = post(body: {
          parcels: parcels,
          last_operation_only: last_operation_only
        }.compact)

        collection(response, Speedy::Models::Tracking::TrackedParcel)
      end

      # POST `/track/bulk`
      def bulk_files(last_processed_file_id:)
        response = post('bulk', body: { last_processed_file_id: last_processed_file_id })

        collection(response, Speedy::Models::Tracking::BulkTrackingDataFile)
      end
    end
  end
end
