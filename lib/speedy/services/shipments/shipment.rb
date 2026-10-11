# frozen_string_literal: true

module Speedy
  module Services
    module Shipments
      class Shipment < Speedy::ServiceResource
        include Speedy::Services::Shipments

        resource_path 'shipment'

        # POST `/shipment`
        def create(service:, content:, payment:, recipient:, sender: nil, **options)
          response = post(body: {
            service: service,
            content: content,
            payment: payment,
            sender: sender,
            recipient: recipient
          }.merge(options).compact)

          resource(response, Speedy::Models::Shipments::CreateShipmentResponse)
        end

        alias create_shipment create

        # POST `/shipment/info`
        def info(shipment_ids)
          response = post('info', body: { shipment_ids: Array(shipment_ids) })

          collection(response, Speedy::Models::Shipments::Shipment)
        end

        # POST `/shipment/update`
        def update(id:, **attributes)
          response = post('update', body: { id: id }.merge(attributes))

          resource(response, Speedy::Models::Shipments::UpdateShipmentResponse)
        end

        # POST `/shipment/update/properties`
        def update_properties(id:, **properties)
          response = post('update/properties', body: { id: id, properties: properties })

          resource(response, Speedy::Models::Shipments::UpdateShipmentResponse)
        end

        # POST `/shipment/cancel`
        def cancel(id:, comment: nil)
          response = post('cancel', body: { shipment_id: id, comment: comment }.compact)

          resource(response, Speedy::Models::Response)
        end

        # POST `/shipment/finalize`
        def finalize(id:)
          response = post('finalize', body: { shipment_id: id })

          resource(response, Speedy::Models::Shipments::CreateShipmentResponse)
        end

        # POST `/shipment/add_parcel`
        def add_parcel(shipment_id:, parcel:, declared_value_amount: nil, cod_amount: nil,
                       cod_fiscal_receipt_items: nil)
          response = post('add_parcel', body: {
            shipment_id: shipment_id,
            parcel: parcel,
            declared_value_amount: declared_value_amount,
            cod_amount: cod_amount,
            cod_fiscal_receipt_items: cod_fiscal_receipt_items
          }.compact)

          resource(response, Speedy::Models::Shipments::CreatedShipmentParcel, key: :parcel)
        end

        # POST `/shipment/{shipmentId}/secondary`
        def secondary(shipment_id:, types: nil)
          response = post("#{shipment_id}/secondary", body: { types: types }.compact)

          collection(response, Speedy::Models::Shipments::SecondaryShipment)
        end

        # POST `/shipment/search`
        def find_by_reference(ref:, search_in_ref:, shipments_only: nil, include_returns: nil,
                              from_date_time: nil, to_date_time: nil)
          response = post('search', body: {
            ref: ref,
            search_in_ref: search_in_ref,
            shipments_only: shipments_only,
            include_returns: include_returns,
            from_date_time: from_date_time,
            to_date_time: to_date_time
          }.compact)

          response.body[:barcodes] || response.body['barcodes'] || []
        end

        # POST `/shipment/handover`
        def hand_over_to_courier(parcels:)
          response = post('handover', body: { parcels: parcels })

          resource(response, Speedy::Models::Response)
        end

        # POST `/shipment/handover-to-midway-carrier`
        def hand_over_to_midway_carrier(parcels:)
          response = post('handover-to-midway-carrier', body: { parcels: parcels })

          resource(response, Speedy::Models::Response)
        end

        # POST `/shipment/barcode-information`
        def barcode_information(parcel:)
          response = post('barcode-information', body: { parcel: parcel })

          resource(response, Speedy::Models::Shipments::BarcodeInformation)
        end
      end
    end
  end
end
