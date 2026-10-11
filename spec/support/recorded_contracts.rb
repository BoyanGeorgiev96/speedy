# frozen_string_literal: true

require 'yaml'
require 'uri'
require_relative 'response_properties'
require_relative 'recorded_contract_assertions'

module SpeedyRecordedContracts
  # Public method, result item/model type, selected response property.
  ROUTES = {
    'location/country' => [:find_countries, Speedy::Models::Location::Country, 'countries'],
    'location/site' => [:find_sites, Speedy::Models::Location::Site, 'sites'],
    'location/office' => [:find_offices, Speedy::Models::Location::Office, 'offices'],
    'location/office/nearest-offices' => [:nearest_offices, Speedy::Models::Location::OfficeResult, 'offices'],
    'location/street' => [:find_streets, Speedy::Models::Location::Street, 'streets'],
    'location/complex' => [:find_complexes, Speedy::Models::Location::Complex, 'complexes'],
    'location/block' => [:find_blocks, Speedy::Models::Location::Block, 'blocks'],
    'location/poi' => [:find_points_of_interest, Speedy::Models::Location::PointOfInterest, 'pois'],
    'location/state' => [:find_states, Speedy::Models::Location::State, 'states'],
    'services' => [:courier_services, Speedy::Models::Services::CourierService, 'services'],
    'client/contract' => [:contract_clients, Speedy::Models::Clients::Client, 'clients'],
    'client/contract/info' => [:contract_info, Speedy::Models::Clients::ContractInfo, nil],
    'track/bulk' => [:bulk_tracking_files, Speedy::Models::Tracking::BulkTrackingDataFile, 'files'],
    'pickup/terms' => [:pickup_terms, Speedy::Models::Pickup::TermsResponse, nil],
    'validation/phone' => [:validate_phone, Speedy::Models::Validation::ValidationResponse, nil],
    'validation/postcode' => [:validate_post_code, Speedy::Models::Validation::ValidationResponse, nil],
    'shipment' => [:create_shipment, Speedy::Models::Shipments::CreateShipmentResponse, nil],
    'shipment/update' => [:update_shipment, Speedy::Models::Shipments::UpdateShipmentResponse, nil],
    'track' => [:track_shipments, Speedy::Models::Tracking::TrackedParcel, 'parcels'],
    'payments' => [:payouts, Speedy::Models::Payments::Payout, 'payouts'],
    'calculate' => [:calculate_delivery, Speedy::Models::Calculation::CalculationResult, 'calculations'],
    'validation/shipment' => [:validate_shipment, Speedy::Models::Validation::ValidationResponse, nil],
    'services/destination' => [:destination_services, Speedy::Models::Services::ExtendedCourierService, 'services'],
    'print/extended' => [:print_labels, Speedy::Models::Print::ExtendedPrintResponse, nil],
    'print/labelInfo' => [:label_info, Speedy::Models::Print::LabelInfoResponse, nil]
  }.freeze

  include ResponseProperties
  include SpeedyRecordedContractAssertions

  def read_recording(path)
    YAML.safe_load_file(path, permitted_classes: [Time], aliases: false).fetch('http_interactions')
  end

  def replay_interaction(interaction)
    request = interaction.fetch('request')
    body = SpeedyVcrSanitizer.parse_json(request.fetch('body').fetch('string'))
    uri = request.fetch('uri').gsub('<SPEEDY_SENDER_CLIENT_ID>', '0')
    route = URI(uri).path.delete_prefix('/v1/')
    client = replay_client(body, uri)
    result, model, selected = replay_call(client, route, replay_arguments(body))
    assert_recorded_result(result, model, selected, interaction)
  end

  def replay_arguments(body)
    Speedy::Util.underscore_keys(body.except('userName', 'password', 'language', 'clientSystemId')).transform_keys(&:to_sym)
  end

  def replay_client(body, uri)
    Speedy::Client.new.tap do |client|
      client.username = body.fetch('userName')
      client.password = body.fetch('password')
      client.language = body['language']
      client.client_system_id = body['clientSystemId']
      client.base_url = uri.sub(%r{/v1/.*\z}, '/v1/')
      client.setup_connection!
    end
  end

  def replay_call(client, route, arguments)
    if ROUTES.key?(route)
      method, model, selected = ROUTES.fetch(route)
      return [client.public_send(method, **arguments), model, selected]
    end
    return replay_special_call(client, route, arguments) unless route.match?(%r{\Alocation/(country|site)/[^/]+\z})

    group, id = route.split('/').last(2)
    model = group == 'country' ? Speedy::Models::Location::Country : Speedy::Models::Location::GetSiteResponse
    [client.public_send("get_#{group}", Integer(id)), model, group == 'country' ? 'country' : nil]
  end

  def replay_special_call(client, route, arguments)
    case route
    when 'client' then [client.own_client_id, Integer, 'clientId']
    when %r{\Aclient/[^/]+\z}
      id = route.split('/').last == '<SPEEDY_SENDER_CLIENT_ID>' ? 0 : Integer(route.split('/').last)
      [client.get_client(id), Speedy::Models::Clients::Client, 'client']
    when 'shipment/info'
      [client.shipment_info(*arguments.fetch(:shipment_ids)), Speedy::Models::Shipments::Shipment, 'shipments']
    when 'shipment/update/properties'
      replay_property_update(client, arguments)
    when 'shipment/cancel'
      [client.cancel_shipment(id: arguments.fetch(:shipment_id), comment: arguments[:comment]), Speedy::Models::Response, nil]
    else replay_print_or_address(client, route, arguments)
    end
  end

  def replay_property_update(client, arguments)
    result = client.update_shipment_properties(id: arguments.fetch(:id), **arguments.fetch(:properties).transform_keys(&:to_sym))
    [result, Speedy::Models::Shipments::UpdateShipmentResponse, nil]
  end

  def replay_print_or_address(client, route, arguments)
    case route
    when 'validation/address'
      [client.validate_address(arguments.fetch(:address)), Speedy::Models::Validation::ValidationResponse, nil]
    when 'print' then [client.print_labels_pdf(**arguments), String, nil]
    when 'print/voucher' then [client.print_voucher(**arguments), String, nil]
    else raise "No public-method replay mapping for #{route}"
    end
  end
end
