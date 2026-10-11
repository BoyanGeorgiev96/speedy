# frozen_string_literal: true

require_relative 'support/response_properties'

RSpec.describe 'Offline endpoint response properties' do
  include ResponseProperties

  examples = Dir[File.join(__dir__, 'fixtures/responses/*.json')].to_h do |path|
    [File.basename(path, '.json'), JSON.parse(File.read(path))]
  end.freeze
  shipment_args = { service: {}, content: {}, payment: {}, recipient: {} }.freeze
  # method, route, fixture, returned portion, positional args, keyword args
  endpoints = [
    [:calculate_delivery, 'calculate', 'CalculationResponse', 'calculations', [], shipment_args],
    [:create_shipment, 'shipment', 'CreateShipmentResponse', nil, [], shipment_args],
    [:shipment_info, 'shipment/info', 'ShipmentInformationResponse', 'shipments', ['7'], {}],
    [:update_shipment, 'shipment/update', 'UpdateShipmentResponse', nil, [], { id: '7' }],
    [:update_shipment_properties, 'shipment/update/properties', 'UpdateShipmentResponse', nil, [], { id: '7' }],
    [:cancel_shipment, 'shipment/cancel', 'CancelShipmentResponse', nil, [], { id: '7' }],
    [:finalize_shipment, 'shipment/finalize', 'FinalizePendingShipmentResponse', nil, [], { id: '7' }],
    [:add_shipment_parcel, 'shipment/add_parcel', 'AddParcelResponse', 'parcel', [], { shipment_id: '7', parcel: {} }],
    [:secondary_shipments, 'shipment/7/secondary', 'SecondaryShipmentsResponse', 'shipments', [], { shipment_id: '7' }],
    [:find_parcels_by_reference, 'shipment/search', 'FindParcelsByRefResponse', 'barcodes', [], { ref: 'example', search_in_ref: 1 }],
    [:hand_over_to_courier, 'shipment/handover', 'HandOverToCourierResponse', nil, [], { parcels: [] }],
    [:hand_over_to_midway_carrier, 'shipment/handover-to-midway-carrier', 'HandOverToMidwayCarrierResponse', nil, [], { parcels: [] }],
    [:barcode_information, 'shipment/barcode-information', 'BarcodeInformationResponse', nil, [], { parcel: {} }],
    [:track_shipments, 'track', 'TrackResponse', 'parcels', [], { parcels: [] }],
    [:bulk_tracking_files, 'track/bulk', 'BulkTrackingDataFilesResponse', 'files', [], { last_processed_file_id: 0 }],
    [:courier_services, 'services', 'ServicesResponse', 'services', [], {}],
    [:destination_services, 'services/destination', 'DestinationServicesResponse', 'services', [], { sender: {}, recipient: {} }],
    [:request_pickup, 'pickup', 'PickupResponse', 'orders', [], { pickup_date_time: '2026-10-12T10:30:00+03:00' }],
    [:pickup_terms, 'pickup/terms', 'PickupTermsResponse', nil, [], { service_id: 505 }],
    [:print_labels, 'print/extended', 'ExtendedPrintResponse', nil, [], { parcels: [] }],
    [:label_info, 'print/labelInfo', 'LabelInfoResponse', nil, [], { parcels: [] }],
    [:own_client_id, 'client', 'GetOwnClientIdResponse', 'clientId', [], {}],
    [:get_client, 'client/7', 'GetClientResponse', 'client', [7], {}],
    [:contract_clients, 'client/contract', 'GetContractClientsResponse', 'clients', [], {}],
    [:create_contact, 'client/contact', 'CreateContactResponse', 'clientId', [], {}],
    [:contact_by_external_id, 'client/contact/external/example', 'GetContactByExternalIdResponse', 'client', [], { id: 'example', secret_key: 'synthetic' }],
    [:contract_info, 'client/contract/info', 'ContractInfo', nil, [], {}],
    [:payouts, 'payments', 'Payout', :payouts, [], { from_date: '2026-10-12', to_date: '2026-10-12' }],
    [:find_countries, 'location/country', 'FindCountryResponse', 'countries', [], {}],
    [:get_country, 'location/country/7', 'GetCountryResponse', 'country', [7], {}],
    [:find_sites, 'location/site', 'FindSiteResponse', 'sites', [], {}],
    [:get_site, 'location/site/7', 'GetSiteResponse', nil, [7], {}],
    [:find_streets, 'location/street', 'FindStreetResponse', 'streets', [], { site_id: 7 }],
    [:get_street, 'location/street/7', 'GetStreetResponse', 'street', [7], {}],
    [:find_offices, 'location/office', 'FindOfficeResponse', 'offices', [], {}],
    [:get_office, 'location/office/7', 'GetOfficeResponse', nil, [7], {}],
    [:nearest_offices, 'location/office/nearest-offices', 'FindNearestOfficesResponse', 'offices', [], { address: {} }],
    [:validate_phone, 'validation/phone', 'ValidationResponse', nil, [], { number: '0000000000' }],
    [:validate_post_code, 'validation/postcode', 'ValidationResponse', nil, [], { country_id: 100, post_code: '1000' }],
    [:validate_address, 'validation/address', 'ValidationResponse', nil, [{}], {}],
    [:validate_shipment, 'validation/shipment', 'ValidationResponse', nil, [], shipment_args],
    [:get_state, 'location/state/7', 'State', 'state', ['7'], {}],
    [:find_states, 'location/state', 'State', 'states', [], {}],
    [:get_complex, 'location/complex/7', 'Complex', 'complex', [7], {}],
    [:find_complexes, 'location/complex', 'Complex', 'complexes', [], { site_id: 7 }],
    [:find_blocks, 'location/block', 'Block', 'blocks', [], { site_id: 7 }],
    [:get_point_of_interest, 'location/poi/7', 'PointOfInterest', 'poi', [7], {}],
    [:find_points_of_interest, 'location/poi', 'PointOfInterest', 'pois', [], { site_id: 7 }]
  ].freeze

  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:client) do
    Speedy::Client.new.tap do |configured|
      configured.username = 'synthetic'
      configured.password = 'synthetic'
      configured.adapter = [:test, stubs]
      configured.setup_connection!
    end
  end

  endpoints.each do |method, route, fixture, selected, arguments, keywords|
    it "preserves every example property through #{method} (#{route})" do
      response = examples.fetch(fixture)
      response = { 'payouts' => [response] } if selected == :payouts
      if %w[State Complex Block PointOfInterest].include?(fixture)
        response = { selected => method.to_s.start_with?('find_') ? [response] : response }
      end
      raw = selected ? response.fetch(selected.to_s) : response
      stubs.post("https://api.speedy.bg/v1/#{route}") do
        [200, { 'Content-Type' => 'application/json' }, JSON.generate(response)]
      end
      actual = client.public_send(method, *arguments, **keywords)
      conversions = case method
                    when :secondary_shipments
                      { '$[0].pickupDate' => ->(value) { Date.parse(value) } }
                    when :payouts
                      date_paths = %w[$[0].date $[0].details[0].pickupDate $[0].details[0].primaryShipmentPickupDate $[0].details[0].deliveryDate]
                      date_paths.to_h { |path| [path, ->(value) { Date.parse(value) }] }
                    else {}
                    end
      expect_response_properties(actual, raw, conversions: conversions)
      stubs.verify_stubbed_calls
    end
  end

  binary_endpoints = [
    [:print_labels_pdf, 'print', { parcels: [] }],
    [:print_voucher, 'print/voucher', { shipment_ids: ['7'] }]
  ].freeze

  binary_endpoints.each do |method, route, keywords|
    it "preserves raw PDF bytes through #{method}" do
      bytes = "%PDF-1.4\nsynthetic\x00\xFF".b
      stubs.post("https://api.speedy.bg/v1/#{route}") { [200, { 'Content-Type' => 'application/pdf' }, bytes] }
      expect(client.public_send(method, **keywords)).to eq(bytes)
      stubs.verify_stubbed_calls
    end
  end

  csv_endpoints = [
    [:all_states, 'state/csv/100', "SOF,Sofia,Sofia,SOF,100\n", { 'id' => 'SOF', 'name' => 'Sofia', 'nameEn' => 'Sofia', 'stateAlpha' => 'SOF', 'countryId' => 100 }],
    [:all_sites, 'site/csv/100', "68134,100,0,гр.,gr.,София,Sofia,Столична,Capital,София,Sofia,1000,2,23.3,42.7,1111110,1,2\n",
     { 'id' => 68_134, 'countryId' => 100, 'mainSiteId' => 0, 'type' => 'гр.', 'typeEn' => 'gr.', 'name' => 'София', 'nameEn' => 'Sofia', 'municipality' => 'Столична', 'municipalityEn' => 'Capital', 'region' => 'София', 'regionEn' => 'Sofia', 'postCode' => '1000', 'addressNomenclature' => 2, 'x' => 23.3, 'y' => 42.7, 'servingDays' => '1111110', 'servingOfficeId' => 1, 'servingHubOfficeId' => 2 }],
    [:all_streets, 'street/csv/100', "1,68134,ул.,str.,Примерна,Example,0\n", { 'id' => 1, 'siteId' => 68_134, 'type' => 'ул.', 'typeEn' => 'str.', 'name' => 'Примерна', 'nameEn' => 'Example', 'actualId' => 0 }],
    [:all_complexes, 'complex/csv/100', "1,68134,кв.,qtr.,Примерен,Example,0\n", { 'id' => 1, 'siteId' => 68_134, 'type' => 'кв.', 'typeEn' => 'qtr.', 'name' => 'Примерен', 'nameEn' => 'Example', 'actualId' => 0 }],
    [:all_blocks, 'block/csv/100', "68134,12,12\n", { 'siteId' => 68_134, 'name' => '12', 'nameEn' => '12' }],
    [:all_points_of_interest, 'poi/csv/100', "1,68134,Пример,Example,Адрес,Address,23.3,42.7,тип,type\n", { 'id' => 1, 'siteId' => 68_134, 'name' => 'Пример', 'nameEn' => 'Example', 'address' => 'Адрес', 'addressEn' => 'Address', 'x' => 23.3, 'y' => 42.7, 'type' => 'тип', 'typeEn' => 'type' }],
    [:all_postcodes, 'postcode/csv/100', "1000,68134\n", { 'postcode' => '1000', 'siteId' => 68_134 }],
    [:all_countries, 'country/csv', "100,България,Bulgaria,BG,BGR,NNNN,0,1,BGN,0,ул.,str.,кв.,qtr.,1\n",
     { 'id' => 100, 'name' => 'България', 'nameEn' => 'Bulgaria', 'isoAlpha2' => 'BG', 'isoAlpha3' => 'BGR', 'postCodeFormats' => ['NNNN'], 'requireState' => false, 'addressType' => 1, 'currencyCode' => 'BGN', 'defaultOfficeId' => 0, 'streetTypes' => [{ 'name' => 'ул.', 'nameEn' => 'str.' }], 'complexTypes' => [{ 'name' => 'кв.', 'nameEn' => 'qtr.' }], 'siteNomen' => 1 }]
  ].freeze

  csv_endpoints.each do |method, route, csv, raw|
    it "checks every CSV column through #{method}" do
      stubs.post("https://api.speedy.bg/v1/location/#{route}") { [200, { 'Content-Type' => 'text/csv' }, csv] }
      keywords = method == :all_countries ? {} : { country_id: 100 }
      expect_response_properties(client.public_send(method, **keywords), [raw])
      stubs.verify_stubbed_calls
    end
  end

  it 'covers every public facade endpoint, with aliases accounted for explicitly' do
    aliases = %i[calculate_delivery_fee]
    covered = endpoints.map(&:first) + binary_endpoints.map(&:first) + csv_endpoints.map(&:first) + aliases
    expect(covered).to match_array(Speedy::ClientResources.public_instance_methods(false))
  end

  it 'checks complete error properties on model and collection responses' do
    raw = examples.fetch('Error')
    stubs.post('https://api.speedy.bg/v1/shipment') { [200, { 'Content-Type' => 'application/json' }, JSON.generate('error' => raw)] }
    stubs.post('https://api.speedy.bg/v1/track') { [200, { 'Content-Type' => 'application/json' }, JSON.generate('error' => raw)] }
    expect_response_properties(client.create_shipment(**shipment_args).error, raw)
    expect_response_properties(client.track_shipments(parcels: []).error, raw)
  end

  it 'checks explicit nullable fields and documents null array coercion' do
    raw = { 'id' => nil, 'price' => nil, 'parcels' => nil, 'pendingParcels' => false }
    stubs.post('https://api.speedy.bg/v1/shipment') { [200, { 'Content-Type' => 'application/json' }, JSON.generate(raw)] }
    expect_response_properties(client.create_shipment(**shipment_args), raw,
                               conversions: { '$.parcels' => ->(_value) { [] } })
  end

  it 'detects a missing accessor rather than treating nil as a preserved property' do
    expect { expect_response_properties(Speedy::Model.new, { 'someValue' => nil }) }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError, /someValue/)
  end

  it 'detects dropped nested properties and incorrect values' do
    expect { expect_response_properties(Speedy::Model.new(nested: Speedy::Model.new), { 'nested' => { 'rawValue' => false } }) }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError, /rawValue/)
    expect { expect_response_properties(Speedy::Model.new(some_value: 1), { 'someValue' => 0 }) }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError, /someValue/)
  end

  it 'rejects raw hashes where a typed nested response model is expected' do
    actual = Speedy::Model.new(nested: { 'rawValue' => false })
    expect { expect_response_properties(actual, { 'nested' => { 'rawValue' => false } }) }
      .to raise_error(RSpec::Expectations::ExpectationNotMetError, /nested/)
  end

  it 'checks unknown properties, acronyms, false, zero and explicit null independently' do
    raw = { 'unknownValue' => nil, 'httpURL' => 'synthetic', 'someCOD' => false, 'ref1' => 0 }
    stubs.post('https://api.speedy.bg/v1/shipment') { [200, { 'Content-Type' => 'application/json' }, JSON.generate(raw)] }
    expect_response_properties(client.create_shipment(**shipment_args), raw)
  end

  it 'checks ordered nested array items, true and zero values through the client' do
    raw = { 'id' => 'example', 'pendingParcels' => true,
            'parcels' => [{ 'id' => 'first', 'seqNo' => 0 }, { 'id' => 'second', 'seqNo' => 2 }],
            'price' => { 'total' => 0, 'details' => { 'basePrice' => { 'amount' => 0 }, 'fuelPrice' => { 'amount' => 5.5 } } } }
    stubs.post('https://api.speedy.bg/v1/shipment') { [200, { 'Content-Type' => 'application/json' }, JSON.generate(raw)] }
    expect_response_properties(client.create_shipment(**shipment_args), raw)
  end

  it 'preserves the empty tracking-detail array observed in existing recordings' do
    raw = { 'parcels' => [{ 'parcelId' => 'synthetic', 'operations' => [], 'externalCarrierParcelNumbersDetails' => [] }] }
    stubs.post('https://api.speedy.bg/v1/track') { [200, { 'Content-Type' => 'application/json' }, JSON.generate(raw)] }
    expect_response_properties(client.track_shipments(parcels: [{ id: 'synthetic' }]), raw.fetch('parcels'))
  end
end
