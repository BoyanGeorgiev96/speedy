# frozen_string_literal: true

module Speedy
  # The public client facade intentionally keeps endpoint shortcuts in one place.
  # rubocop:disable-next Metrics/ModuleLength
  module ClientResources
    # Calculate available delivery prices without creating a shipment.
    # @param args [Hash] Endpoint keywords in snake_case; see docs/API.md for the expanded signature.
    # @option args [Hash, Speedy::Model] recipient Required. Recipient shipment party.
    # @option args [Hash, Speedy::Model] service Required. Service settings: service_ids for calculation,
    #   service_id for creation.
    # @option args [Hash, Speedy::Model] content Required. Parcel count, contents and weight.
    # @option args [Hash, Speedy::Model] payment Required. Payer and payment settings.
    # @option args [Hash, Speedy::Model, nil] sender (nil) Sender party; nil uses account defaults when permitted.
    # @return [Speedy::Collection<Speedy::Models::Calculation::CalculationResult>] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.calculate_delivery(**quote_attributes)
    def calculate_delivery(**args)
      Speedy::Services::Calculation.new(client: self).calculate(**args)
    end

    alias calculate_delivery_fee calculate_delivery

    # Create a shipment; retain its identifier for subsequent reads and cleanup.
    # @note Mutates remote state. See docs/VCR.md for cleanup limitations.
    # @param args [Hash] Endpoint keywords in snake_case; see docs/API.md for the expanded signature.
    # @option args [Hash, Speedy::Model] service Required. Service settings: service_ids for calculation,
    #   service_id for creation.
    # @option args [Hash, Speedy::Model] content Required. Parcel count, contents and weight.
    # @option args [Hash, Speedy::Model] payment Required. Payer and payment settings.
    # @option args [Hash, Speedy::Model] recipient Required. Recipient shipment party.
    # @option args [Hash, Speedy::Model, nil] sender (nil) Sender party; nil uses account defaults when permitted.
    # @return [Speedy::Models::Shipments::CreateShipmentResponse] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.create_shipment(**shipment_attributes)
    def create_shipment(**args)
      shipment_service.create(**args)
    end

    # Retrieve shipment details; accepts individual IDs or an array.
    # @param shipment_ids [Array<String>] Existing shipment IDs; an array may also be passed.
    # @return [Speedy::Collection<Speedy::Models::Shipments::Shipment>] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.shipment_info(shipment_id)
    def shipment_info(*shipment_ids)
      shipment_service.info(shipment_ids.flatten)
    end

    # Replace/update full shipment data using fields accepted by the shipment update endpoint.
    # @note Mutates remote state. See docs/VCR.md for cleanup limitations.
    # @param id [Integer, String] Existing resource identifier.
    # @param args [Hash] Endpoint keywords in snake_case; see docs/API.md for the expanded signature.
    # @return [Speedy::Models::Shipments::UpdateShipmentResponse] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.update_shipment(id: shipment_id, **shipment_attributes)
    def update_shipment(id:, **args)
      shipment_service.update(id: id, **args)
    end

    # Update selected shipment properties; keywords are nested inside properties automatically.
    # @note Mutates remote state. See docs/VCR.md for cleanup limitations.
    # @param id [Integer, String] Existing resource identifier.
    # @param properties [Hash] Endpoint keywords in snake_case; see docs/API.md for the expanded signature.
    # @return [Speedy::Models::Shipments::UpdateShipmentResponse] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.update_shipment_properties(id: shipment_id, contents: "Artwork")
    def update_shipment_properties(id:, **properties)
      shipment_service.update_properties(id: id, **properties)
    end

    # Cancel an eligible shipment; inspect success? and error before treating cleanup as complete.
    # @note Mutates remote state. See docs/VCR.md for cleanup limitations.
    # @param id [Integer, String] Existing resource identifier.
    # @param comment [String, nil] Cancellation comment.
    # @return [Speedy::Models::Response] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.cancel_shipment(id: shipment_id, comment: "Synthetic test cleanup")
    def cancel_shipment(id:, comment: nil)
      shipment_service.cancel(id: id, comment: comment)
    end

    # Finalize a shipment that is awaiting parcel completion; requires applicable account permissions.
    # @note Mutates remote state. See docs/VCR.md for cleanup limitations.
    # @param id [Integer, String] Existing resource identifier.
    # @return [Speedy::Models::Shipments::CreateShipmentResponse] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.finalize_shipment(id: shipment_id)
    def finalize_shipment(id:)
      shipment_service.finalize(id: id)
    end

    # Add a parcel to an eligible pending shipment; standard demo accounts may lack permission.
    # @note Mutates remote state. See docs/VCR.md for cleanup limitations.
    # @param shipment_id [String] Existing shipment identifier.
    # @param parcel [Hash] Parcel reference or attributes appropriate to this endpoint.
    # @param args [Hash] Endpoint keywords in snake_case; see docs/API.md for the expanded signature.
    # @option args [Object] declared_value_amount (nil) API declared value amount option.
    # @option args [Object] cod_amount (nil) API cod amount option.
    # @option args [Object] cod_fiscal_receipt_items (nil) API cod fiscal receipt items option.
    # @return [Speedy::Models::Shipments::CreatedShipmentParcel] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.add_shipment_parcel(shipment_id: shipment_id, parcel: { weight: 0.1 })
    def add_shipment_parcel(shipment_id:, parcel:, **args)
      shipment_service.add_parcel(shipment_id: shipment_id, parcel: parcel, **args)
    end

    # List secondary shipments associated with a shipment.
    # @param shipment_id [String] Existing shipment identifier.
    # @param types [Array<String>, nil] Secondary shipment type filters.
    # @return [Speedy::Collection<Speedy::Models::Shipments::SecondaryShipment>] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.secondary_shipments(shipment_id: shipment_id)
    def secondary_shipments(shipment_id:, types: nil)
      shipment_service.secondary(shipment_id: shipment_id, types: types)
    end

    # Find barcode strings by a shipment reference; search_in_ref selects reference fields.
    # @param ref [String] Reference search value.
    # @param search_in_ref [Integer] API reference-field selector.
    # @param args [Hash] Endpoint keywords in snake_case; see docs/API.md for the expanded signature.
    # @option args [Object] shipments_only (nil) API shipments only option.
    # @option args [Object] include_returns (nil) API include returns option.
    # @option args [Object] from_date_time (nil) API from date time option.
    # @option args [Object] to_date_time (nil) API to date time option.
    # @return [Array<String>] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.find_parcels_by_reference(ref: "order-123", search_in_ref: 1)
    def find_parcels_by_reference(ref:, search_in_ref:, **args)
      shipment_service.find_by_reference(ref: ref, search_in_ref: search_in_ref, **args)
    end

    # Register parcel handover to a courier; not a dry-run operation.
    # @note Mutates remote state. See docs/VCR.md for cleanup limitations.
    # @param parcels [Array<Hash>] Parcel references in the endpoint-specific shape.
    # @return [Speedy::Models::Response] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.hand_over_to_courier(parcels: [{ id: parcel_id }])
    def hand_over_to_courier(parcels:)
      shipment_service.hand_over_to_courier(parcels: parcels)
    end

    # Register parcel handover to a midway carrier.
    # @note Mutates remote state. See docs/VCR.md for cleanup limitations.
    # @param parcels [Array<Hash>] Parcel references in the endpoint-specific shape.
    # @return [Speedy::Models::Response] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.hand_over_to_midway_carrier(parcels: [{ id: parcel_id }])
    def hand_over_to_midway_carrier(parcels:)
      shipment_service.hand_over_to_midway_carrier(parcels: parcels)
    end

    # Retrieve barcode information for a parcel reference.
    # @param parcel [Hash] Parcel reference or attributes appropriate to this endpoint.
    # @return [Speedy::Models::Shipments::BarcodeInformation] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.barcode_information(parcel: { id: parcel_id })
    def barcode_information(parcel:)
      shipment_service.barcode_information(parcel: parcel)
    end

    # Retrieve parcel tracking operations; true requests only the latest operation.
    # @param parcels [Array<Hash>] Parcel references in the endpoint-specific shape.
    # @param last_operation_only [Boolean, nil] True requests only the latest operation.
    # @return [Speedy::Collection<Speedy::Models::Tracking::TrackedParcel>] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.track_shipments(parcels: [{ id: parcel_id }], last_operation_only: true)
    def track_shipments(parcels:, last_operation_only: nil)
      Speedy::Services::Tracking.new(client: self).track(
        parcels: parcels, last_operation_only: last_operation_only
      )
    end

    # List available tracking files after a cursor; URLs are returned, not downloaded.
    # @param last_processed_file_id [Integer] Tracking-file cursor.
    # @return [Speedy::Collection<Speedy::Models::Tracking::BulkTrackingDataFile>] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.bulk_tracking_files(last_processed_file_id: 0)
    def bulk_tracking_files(last_processed_file_id:)
      Speedy::Services::Tracking.new(client: self).bulk_files(
        last_processed_file_id: last_processed_file_id
      )
    end

    # List courier services, optionally for an ISO date.
    # @param date [String, nil] ISO calendar date; nil uses the server default.
    # @return [Speedy::Collection<Speedy::Models::Services::CourierService>] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.courier_services
    def courier_services(date: nil)
      Speedy::Services::CourierServices.new(client: self).all(date: date)
    end

    # List services available for the supplied shipment parties.
    # @param sender [Hash, Speedy::Model, nil] Sender party; nil uses account defaults when permitted.
    # @param recipient [Hash, Speedy::Model] Recipient shipment party.
    # @param date [String, nil] ISO calendar date; nil uses the server default.
    # @return [Speedy::Collection<Speedy::Models::Services::ExtendedCourierService>] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.destination_services(sender: sender, recipient: recipient)
    def destination_services(sender:, recipient:, date: nil)
      Speedy::Services::CourierServices.new(client: self).for_destination(
        sender: sender, recipient: recipient, date: date
      )
    end

    # Request a courier visit; auto_adjust_pickup_date allows server adjustment when supported.
    # @note Mutates remote state. See docs/VCR.md for cleanup limitations.
    # @param args [Hash] Endpoint keywords in snake_case; see docs/API.md for the expanded signature.
    # @option args [String] pickup_date_time Required. Desired pickup datetime.
    # @option args [Object] pickup_scope (nil) API pickup scope option.
    # @option args [Array<String>, nil] explicit_shipment_id_list (nil) Shipment IDs included in the pickup.
    # @option args [Object] visit_end_time (nil) API visit end time option.
    # @option args [Object] contact_name (nil) API contact name option.
    # @option args [Object] phone_number (nil) API phone number option.
    # @option args [Boolean, nil] auto_adjust_pickup_date (nil) Allow server adjustment of the pickup day.
    # @return [Speedy::Collection<Speedy::Models::Pickup::PickupOrder>] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.request_pickup(pickup_date_time: pickup_date_time, explicit_shipment_id_list: [shipment_id])
    def request_pickup(**args)
      Speedy::Services::Pickup.new(client: self).create(**args)
    end

    # Retrieve available pickup terms for a service and sender.
    # @param service_id [Integer] Courier service identifier.
    # @param args [Hash] Endpoint keywords in snake_case; see docs/API.md for the expanded signature.
    # @option args [Object] starting_date (nil) API starting date option.
    # @option args [Hash, Speedy::Model, nil] sender (nil) Sender party; nil uses account defaults when permitted.
    # @option args [Object] sender_has_payment (nil) API sender has payment option.
    # @return [Speedy::Models::Pickup::TermsResponse] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.pickup_terms(service_id: 505)
    def pickup_terms(service_id:, **args)
      Speedy::Services::Pickup.new(client: self).terms(service_id: service_id, **args)
    end

    # Get extended labels with encoded document data and label metadata.
    # @note printer_name may trigger physical printing; omit it to download only.
    # @param args [Hash] Endpoint keywords in snake_case; see docs/API.md for the expanded signature.
    # @option args [Array<Hash>] parcels Required. Parcel references in the endpoint-specific shape.
    # @option args [String, nil] format (nil) Document format, e.g. pdf or zpl.
    # @option args [String, nil] paper_size (nil) Paper format, e.g. A4 or A6.
    # @option args [String, nil] printer_name (nil) Optional physical printer; omit for download-only use.
    # @option args [Integer, nil] dpi (nil) Print resolution.
    # @option args [Object] additional_waybill_sender_copy (nil) API additional waybill sender copy option.
    # @return [Speedy::Models::Print::ExtendedPrintResponse] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.print_labels(parcels: [{ parcel: { id: parcel_id } }], format: "pdf")
    def print_labels(**args)
      Speedy::Services::Print.new(client: self).create_pdf_extended(**args)
    end

    # Get raw label document bytes; despite its name, format may request ZPL.
    # @note printer_name may trigger physical printing; omit it to download only.
    # @param args [Hash] Endpoint keywords in snake_case; see docs/API.md for the expanded signature.
    # @option args [Array<Hash>] parcels Required. Parcel references in the endpoint-specific shape.
    # @option args [String, nil] format (nil) Document format, e.g. pdf or zpl.
    # @option args [String, nil] paper_size (nil) Paper format, e.g. A4 or A6.
    # @option args [String, nil] printer_name (nil) Optional physical printer; omit for download-only use.
    # @option args [Integer, nil] dpi (nil) Print resolution.
    # @option args [Object] additional_waybill_sender_copy (nil) API additional waybill sender copy option.
    # @return [String] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.print_labels_pdf(parcels: [{ parcel: { id: parcel_id } }], format: "pdf")
    def print_labels_pdf(**args)
      Speedy::Services::Print.new(client: self).create_pdf(**args).body
    end

    # Retrieve label metadata; prefer an explicit parcels array.
    # @param args [Hash] Endpoint keywords in snake_case; see docs/API.md for the expanded signature.
    # @option args [Hash, Array<Hash>, nil] parcel (nil) Single parcel reference or an array of references.
    # @option args [Array<Hash>] parcels (nil) Parcel references in the endpoint-specific shape.
    # @return [Speedy::Models::Print::LabelInfoResponse] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.label_info(parcels: [{ id: parcel_id }])
    def label_info(**args)
      Speedy::Services::Print.new(client: self).label_info(**args)
    end

    # Get raw voucher PDF/ZPL bytes for shipment IDs.
    # @note printer_name may trigger physical printing; omit it to download only.
    # @param shipment_ids [Array<String>] Existing shipment IDs; an array may also be passed.
    # @param args [Hash] Endpoint keywords in snake_case; see docs/API.md for the expanded signature.
    # @option args [String, nil] printer_name (nil) Optional physical printer; omit for download-only use.
    # @option args [String, nil] format (nil) Document format, e.g. pdf or zpl.
    # @option args [Integer, nil] dpi (nil) Print resolution.
    # @return [String] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.print_voucher(shipment_ids: [shipment_id], format: "pdf")
    def print_voucher(shipment_ids:, **args)
      Speedy::Services::Print.new(client: self).voucher(shipment_ids: shipment_ids, **args)
    end

    # Retrieve the authenticated client identifier.
    # @return [Integer, nil] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.own_client_id
    def own_client_id
      Speedy::Services::Clients.new(client: self).own_id
    end

    # Retrieve a client by identifier.
    # @param id [Integer, String] Existing resource identifier.
    # @return [Speedy::Models::Clients::Client] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.get_client(client_id)
    def get_client(id)
      Speedy::Services::Clients.new(client: self).get(id)
    end

    # List clients available under the authenticated contract.
    # @return [Speedy::Collection<Speedy::Models::Clients::Client>] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.contract_clients
    def contract_clients
      Speedy::Services::Clients.new(client: self).contract_clients
    end

    # Create a contact; forwards compacted contact attributes accepted by the API.
    # @note Mutates remote state. See docs/VCR.md for cleanup limitations.
    # @param args [Hash] Endpoint keywords in snake_case; see docs/API.md for the expanded signature.
    # @return [Integer, nil] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.create_contact(client_name: "Synthetic Contact", private_person: true, phone1: { number:
    #   "+359888000000" }, address: address)
    def create_contact(**args)
      Speedy::Services::Clients.new(client: self).create_contact(**args)
    end

    # Retrieve a contact using its external ID and secret; do not log the secret.
    # @param id [Integer, String] Existing resource identifier.
    # @param secret_key [String] External contact secret; do not log it.
    # @return [Speedy::Models::Clients::Client] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.contact_by_external_id(id: external_contact_id, secret_key: external_contact_secret)
    def contact_by_external_id(id:, secret_key:)
      Speedy::Services::Clients.new(client: self).contact_by_external_id(id: id, secret_key: secret_key)
    end

    # Retrieve contract information for the authenticated account.
    # @return [Speedy::Models::Clients::ContractInfo] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.contract_info
    def contract_info
      Speedy::Services::Clients.new(client: self).contract_info
    end

    # Retrieve payouts within an ISO-date interval; dates are cast to Ruby Date values where supported.
    # @param from_date [String] ISO starting date.
    # @param to_date [String] ISO ending date.
    # @param include_details [Boolean, nil] Include individual payout details.
    # @return [Speedy::Collection<Speedy::Models::Payments::Payout>] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.payouts(from_date: "2026-10-01", to_date: "2026-10-10", include_details: true)
    def payouts(from_date:, to_date:, include_details: nil)
      Speedy::Services::Payments.new(client: self).payouts(
        from_date: from_date, to_date: to_date, include_details: include_details
      )
    end

    # Search cities/localities with optional filters.
    # @param args [Hash] Endpoint keywords in snake_case; see docs/API.md for the expanded signature.
    # @option args [Integer, nil] country_id (nil) Country nomenclature identifier.
    # @option args [String, nil] name (nil) Name filter.
    # @option args [String, nil] post_code (nil) Postal code.
    # @option args [Object] type (nil) API type option.
    # @option args [Object] municipality (nil) API municipality option.
    # @option args [Object] region (nil) API region option.
    # @return [Speedy::Collection<Speedy::Models::Location::Site>] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.find_sites(country_id: 100, name: "София")
    def find_sites(**args)
      Speedy::Services::Location::Site.new(client: self).find(**args)
    end

    # Get a site response envelope; the site is available through result.site.
    # @param id [Integer, String] Existing resource identifier.
    # @return [Speedy::Models::Location::GetSiteResponse] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.get_site(site_id)
    def get_site(id)
      Speedy::Services::Location::Site.new(client: self).get(id)
    end

    # Retrieve a state by its identifier.
    # @param id [Integer, String] Existing resource identifier.
    # @return [Speedy::Models::Location::State] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.get_state(state_id)
    def get_state(id)
      Speedy::Services::Location::State.new(client: self).get(id)
    end

    # Search states with optional country and name filters.
    # @param args [Hash] Endpoint keywords in snake_case; see docs/API.md for the expanded signature.
    # @option args [Integer, nil] country_id (nil) Country nomenclature identifier.
    # @option args [String, nil] name (nil) Name filter.
    # @return [Speedy::Collection<Speedy::Models::Location::State>] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.find_states(country_id: country_id)
    def find_states(**args)
      Speedy::Services::Location::State.new(client: self).find(**args)
    end

    # Download and parse the state CSV dataset for a country.
    # @param args [Hash] Endpoint keywords in snake_case; see docs/API.md for the expanded signature.
    # @option args [Integer, nil] country_id Required. Country nomenclature identifier.
    # @return [Speedy::Collection<Speedy::Models::Location::State>] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.all_states(country_id: country_id)
    def all_states(**args)
      Speedy::Services::Location::State.new(client: self).all(**args)
    end

    # Download and parse the country CSV dataset.
    # @return [Speedy::Collection<Speedy::Models::Location::Country>] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.all_countries
    def all_countries
      Speedy::Services::Location::Country.new(client: self).all
    end

    # Download and parse the sites CSV dataset for a country.
    # @param country_id [Integer, nil] Country nomenclature identifier.
    # @return [Speedy::Collection<Speedy::Models::Location::Site>] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.all_sites(country_id: 100)
    def all_sites(country_id:)
      Speedy::Services::Location::Site.new(client: self).all(country_id: country_id)
    end

    # Download and parse the streets CSV dataset for a country.
    # @param country_id [Integer, nil] Country nomenclature identifier.
    # @return [Speedy::Collection<Speedy::Models::Location::Street>] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.all_streets(country_id: 100)
    def all_streets(country_id:)
      Speedy::Services::Location::Street.new(client: self).all(country_id: country_id)
    end

    # Download and parse the complexes CSV dataset for a country.
    # @param country_id [Integer, nil] Country nomenclature identifier.
    # @return [Speedy::Collection<Speedy::Models::Location::Complex>] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.all_complexes(country_id: 100)
    def all_complexes(country_id:)
      Speedy::Services::Location::Complex.new(client: self).all(country_id: country_id)
    end

    # Download and parse the blocks CSV dataset for a country.
    # @param country_id [Integer, nil] Country nomenclature identifier.
    # @return [Speedy::Collection<Speedy::Models::Location::Block>] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.all_blocks(country_id: 100)
    def all_blocks(country_id:)
      Speedy::Services::Location::Block.new(client: self).all(country_id: country_id)
    end

    # Download and parse the points of interest CSV dataset for a country.
    # @param country_id [Integer, nil] Country nomenclature identifier.
    # @return [Speedy::Collection<Speedy::Models::Location::PointOfInterest>] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.all_points_of_interest(country_id: 100)
    def all_points_of_interest(country_id:)
      Speedy::Services::Location::PointOfInterest.new(client: self).all(country_id: country_id)
    end

    # Download and parse the postcodes CSV dataset for a country.
    # @param country_id [Integer, nil] Country nomenclature identifier.
    # @return [Speedy::Collection<Speedy::Models::Location::Postcode>] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.all_postcodes(country_id: 100)
    def all_postcodes(country_id:)
      Speedy::Services::Location::Postcode.new(client: self).all(country_id: country_id)
    end

    # Search countries by name or ISO code.
    # @param args [Hash] Endpoint keywords in snake_case; see docs/API.md for the expanded signature.
    # @option args [String, nil] name (nil) Name filter.
    # @option args [Object] iso_alpha2 (nil) API iso alpha2 option.
    # @option args [Object] iso_alpha3 (nil) API iso alpha3 option.
    # @return [Speedy::Collection<Speedy::Models::Location::Country>] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.find_countries(iso_alpha2: "BG")
    def find_countries(**args)
      Speedy::Services::Location::Country.new(client: self).find(**args)
    end

    # Retrieve a country by identifier.
    # @param id [Integer, String] Existing resource identifier.
    # @return [Speedy::Models::Location::Country] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.get_country(100)
    def get_country(id)
      Speedy::Services::Location::Country.new(client: self).get(id)
    end

    # Search streets within a site.
    # @param args [Hash] Endpoint keywords in snake_case; see docs/API.md for the expanded signature.
    # @option args [Integer, nil] site_id Required. Locality nomenclature identifier.
    # @option args [String, nil] name (nil) Name filter.
    # @option args [Object] type (nil) API type option.
    # @return [Speedy::Collection<Speedy::Models::Location::Street>] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.find_streets(site_id: site_id, name: "Витоша")
    def find_streets(**args)
      Speedy::Services::Location::Street.new(client: self).find(**args)
    end

    # Retrieve a street by identifier.
    # @param id [Integer, String] Existing resource identifier.
    # @return [Speedy::Models::Location::Street] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.get_street(street_id)
    def get_street(id)
      Speedy::Services::Location::Street.new(client: self).get(id)
    end

    # Search complexes within a site.
    # @param args [Hash] Endpoint keywords in snake_case; see docs/API.md for the expanded signature.
    # @option args [Integer, nil] site_id Required. Locality nomenclature identifier.
    # @option args [String, nil] name (nil) Name filter.
    # @option args [Object] type (nil) API type option.
    # @return [Speedy::Collection<Speedy::Models::Location::Complex>] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.find_complexes(site_id: site_id, name: "Витоша")
    def find_complexes(**args)
      Speedy::Services::Location::Complex.new(client: self).find(**args)
    end

    # Retrieve a complex by identifier.
    # @param id [Integer, String] Existing resource identifier.
    # @return [Speedy::Models::Location::Complex] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.get_complex(complex_id)
    def get_complex(id)
      Speedy::Services::Location::Complex.new(client: self).get(id)
    end

    # Search block/building numbers within a site.
    # @param args [Hash] Endpoint keywords in snake_case; see docs/API.md for the expanded signature.
    # @option args [Integer, nil] site_id Required. Locality nomenclature identifier.
    # @option args [String, nil] name (nil) Name filter.
    # @return [Speedy::Collection<Speedy::Models::Location::Block>] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.find_blocks(site_id: site_id, name: "1")
    def find_blocks(**args)
      Speedy::Services::Location::Block.new(client: self).find(**args)
    end

    # Search points of interest within a site.
    # @param args [Hash] Endpoint keywords in snake_case; see docs/API.md for the expanded signature.
    # @option args [Integer, nil] site_id Required. Locality nomenclature identifier.
    # @option args [String, nil] name (nil) Name filter.
    # @return [Speedy::Collection<Speedy::Models::Location::PointOfInterest>] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.find_points_of_interest(site_id: site_id)
    def find_points_of_interest(**args)
      Speedy::Services::Location::PointOfInterest.new(client: self).find(**args)
    end

    # Retrieve a point of interest by identifier.
    # @param id [Integer, String] Existing resource identifier.
    # @return [Speedy::Models::Location::PointOfInterest] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.get_point_of_interest(point_of_interest_id)
    def get_point_of_interest(id)
      Speedy::Services::Location::PointOfInterest.new(client: self).get(id)
    end

    # Search offices and lockers with optional locality/name filters.
    # @param args [Hash] Endpoint keywords in snake_case; see docs/API.md for the expanded signature.
    # @option args [Integer, nil] country_id (nil) Country nomenclature identifier.
    # @option args [Integer, nil] site_id (nil) Locality nomenclature identifier.
    # @option args [Object] site_name (nil) API site name option.
    # @option args [String, nil] name (nil) Name filter.
    # @option args [Integer, nil] limit (nil) Maximum result count.
    # @return [Speedy::Collection<Speedy::Models::Location::Office>] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.find_offices(site_id: site_id, limit: 10)
    def find_offices(**args)
      Speedy::Services::Location::Office.new(client: self).find(**args)
    end

    # Retrieve an office response envelope; the office is available through result.office.
    # @param id [Integer, String] Existing resource identifier.
    # @return [Speedy::Models::Location::GetOfficeResponse] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.get_office(office_id)
    def get_office(id)
      Speedy::Services::Location::Office.new(client: self).get(id)
    end

    # Find offices near an address; items contain office and distance metadata.
    # @param address [Hash, Speedy::Models::Shipments::ShipmentAddress] Shipment address.
    # @param args [Hash] Endpoint keywords in snake_case; see docs/API.md for the expanded signature.
    # @option args [Numeric, nil] distance (nil) Search distance in API-defined units.
    # @option args [Integer, nil] limit (nil) Maximum result count.
    # @option args [Object] office_type (nil) API office type option.
    # @option args [Object] office_features (nil) API office features option.
    # @return [Speedy::Collection<Speedy::Models::Location::OfficeResult>] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.nearest_offices(address: address, limit: 5)
    def nearest_offices(address:, **args)
      Speedy::Services::Location::Office.new(client: self).nearest(address: address, **args)
    end

    # Validate a shipment address supplied as a hash or ShipmentAddress model.
    # @param address [Hash, Speedy::Models::Shipments::ShipmentAddress] Shipment address.
    # @return [Speedy::Models::Validation::ValidationResponse] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.validate_address(address)
    def validate_address(address)
      Speedy::Services::Validation::Address.new(client: self).validate_address(address)
    end

    # Validate a phone number, optionally including an extension.
    # @param number [String] Phone number.
    # @param extension [String, nil] Phone extension.
    # @return [Speedy::Models::Validation::ValidationResponse] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.validate_phone(number: "+359888000000")
    def validate_phone(number:, extension: nil)
      Speedy::Services::Validation::General.new(client: self).phone(number: number, extension: extension)
    end

    # Validate a postcode against a country and optional site.
    # @param country_id [Integer, nil] Country nomenclature identifier.
    # @param post_code [String, nil] Postal code.
    # @param site_id [Integer, nil] Locality nomenclature identifier.
    # @return [Speedy::Models::Validation::ValidationResponse] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.validate_post_code(country_id: 100, post_code: "1000")
    def validate_post_code(country_id:, post_code:, site_id: nil)
      Speedy::Services::Validation::General.new(client: self).post_code(
        country_id: country_id, post_code: post_code, site_id: site_id
      )
    end

    # Validate shipment attributes without creating a shipment.
    # @param args [Hash] Endpoint keywords in snake_case; see docs/API.md for the expanded signature.
    # @option args [Hash, Speedy::Model] service Required. Service settings: service_ids for calculation,
    #   service_id for creation.
    # @option args [Hash, Speedy::Model] content Required. Parcel count, contents and weight.
    # @option args [Hash, Speedy::Model] payment Required. Payer and payment settings.
    # @option args [Hash, Speedy::Model] recipient Required. Recipient shipment party.
    # @option args [Hash, Speedy::Model, nil] sender (nil) Sender party; nil uses account defaults when permitted.
    # @return [Speedy::Models::Validation::ValidationResponse] Endpoint result.
    # @raise [Speedy::Error] Unsuccessful HTTP response.
    # @raise [Speedy::TransportError] Connection, timeout or TLS failure; preserves the original cause.
    # @example After configuring the client and supplying account-specific fixtures
    #   client.validate_shipment(**shipment_attributes)
    def validate_shipment(**args)
      Speedy::Services::Validation::General.new(client: self).shipment(**args)
    end

    private

    def shipment_service
      Speedy::Services::Shipments::Shipment.new(client: self)
    end
  end
end
