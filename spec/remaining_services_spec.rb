# frozen_string_literal: true

RSpec.describe 'Speedy remaining schema-backed services' do
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:client) do
    Speedy::Client.new.tap do |configured_client|
      configured_client.username = 'speedy-user'
      configured_client.password = 'speedy-pass'
      configured_client.adapter = [:test, stubs]
      configured_client.setup_connection!
    end
  end

  it 'retrieves client, contact, and contract information' do
    stubs.post('https://api.speedy.bg/v1/client') do
      [200, { 'Content-Type' => 'application/json' }, { clientId: 123 }.to_json]
    end
    stubs.post('https://api.speedy.bg/v1/client/123') do
      [200, { 'Content-Type' => 'application/json' },
       { client: { clientId: 123, clientName: 'Gallery', phones: [{ number: '123' }] } }.to_json]
    end
    stubs.post('https://api.speedy.bg/v1/client/contract') do
      [200, { 'Content-Type' => 'application/json' },
       { clients: [{ clientId: 123, clientName: 'Gallery' }] }.to_json]
    end
    stubs.post('https://api.speedy.bg/v1/client/contact') do |env|
      expect(JSON.parse(env.body)).to include(
        'externalContactId' => 'customer-1', 'secretKey' => 'secret'
      )
      [200, { 'Content-Type' => 'application/json' }, { clientId: 456 }.to_json]
    end
    stubs.post('https://api.speedy.bg/v1/client/contact/external/customer-1') do |env|
      expect(JSON.parse(env.body)).to include('secretKey' => 'secret')
      [200, { 'Content-Type' => 'application/json' },
       { client: { clientId: 456, externalContactId: 'customer-1' } }.to_json]
    end
    stubs.post('https://api.speedy.bg/v1/client/contract/info') do
      body = {
        id: 7,
        administrativeFeeAllowed: true,
        specialDeliveryRequirements: {
          requiredForAllShipments: false,
          requirements: [{ id: 1, text: 'Call first' }]
        },
        cod: {
          moneyTransferAllowed: true,
          internationalCODAnnexes: [{ countryId: 100, countryName: 'Bulgaria' }]
        }
      }
      [200, { 'Content-Type' => 'application/json' }, body.to_json]
    end

    expect(client.own_client_id).to eq(123)
    expect(client.get_client(123).phones.first.number).to eq('123')
    expect(client.contract_clients.first.client_name).to eq('Gallery')
    contact_id = client.create_contact(
      external_contact_id: 'customer-1', secret_key: 'secret', phone1: { number: '123' },
      client_name: 'Customer', address: { site_id: 68_134, street_no: '1' }
    )
    expect(contact_id).to eq(456)
    expect(client.contact_by_external_id(id: 'customer-1', secret_key: 'secret').client_id).to eq(456)
    contract = client.contract_info
    expect(contract.special_delivery_requirements.requirements.first.text).to eq('Call first')
    expect(contract.cod.international_cod_annexes.first.country_id).to eq(100)
  end

  it 'updates full shipment data and handles secondary shipment lookup' do
    stubs.post('https://api.speedy.bg/v1/shipment/update') do |env|
      expect(JSON.parse(env.body)).to include(
        'id' => '700000001',
        'service' => { 'serviceId' => 505 },
        'recipient' => { 'clientId' => 123 }
      )
      [200, { 'Content-Type' => 'application/json' }, { id: '700000001', parcels: [] }.to_json]
    end
    stubs.post('https://api.speedy.bg/v1/shipment/700000001/secondary') do |env|
      expect(JSON.parse(env.body)).to include('types' => ['RETURN_SHIPMENT'])
      body = {
        shipments: [{
          id: '700000002', type: 'RETURN_SHIPMENT', pickupDate: '2026-10-06',
          hasScans: true, parcels: [{ id: '700000002001', seqNo: 1 }]
        }]
      }
      [200, { 'Content-Type' => 'application/json' }, body.to_json]
    end

    updated = client.update_shipment(
      id: '700000001', service: { service_id: 505 }, recipient: { client_id: 123 }
    )
    secondary = client.secondary_shipments(
      shipment_id: '700000001', types: ['RETURN_SHIPMENT']
    ).first

    expect(updated.id).to eq('700000001')
    expect(secondary.type).to eq('RETURN_SHIPMENT')
    expect(secondary.parcels.first.seq_no).to eq(1)
  end

  it 'searches parcel references and records both handover variants' do
    stubs.post('https://api.speedy.bg/v1/shipment/search') do |env|
      expect(JSON.parse(env.body)).to include('ref' => 'ORDER-1', 'searchInRef' => 1)
      [200, { 'Content-Type' => 'application/json' }, { barcodes: ['700000001001'] }.to_json]
    end
    stubs.post('https://api.speedy.bg/v1/shipment/handover') do |env|
      expect(JSON.parse(env.body)['parcels'].first).to include('id' => '700000001001')
      [200, { 'Content-Type' => 'application/json' }, {}.to_json]
    end
    stubs.post('https://api.speedy.bg/v1/shipment/handover-to-midway-carrier') do |env|
      expect(JSON.parse(env.body)['parcels'].first).to include('countryId' => 100)
      [200, { 'Content-Type' => 'application/json' }, {}.to_json]
    end

    expect(client.find_parcels_by_reference(ref: 'ORDER-1', search_in_ref: 1)).to eq(['700000001001'])
    courier_handover = client.hand_over_to_courier(
      parcels: [{ id: '700000001001', date_time: '2026-10-06T12:00:00+03:00' }]
    )
    midway_handover = client.hand_over_to_midway_carrier(
      parcels: [{ id: '700000001001', date_time: 1_759_742_400_000, country_id: 100 }]
    )
    expect(courier_handover).to be_success
    expect(midway_handover).to be_success
  end

  it 'retrieves barcode information, pickup terms, and bulk tracking files' do
    stubs.post('https://api.speedy.bg/v1/shipment/barcode-information') do |env|
      expect(JSON.parse(env.body)).to include('parcel' => { 'id' => '700000001001' })
      body = {
        primaryShipment: { id: '700000001', type: 'FORWARD' },
        primaryParcelId: '700000001001',
        labelInfo: { parcelId: '700000001001', fullBarcode: 'BRC' }
      }
      [200, { 'Content-Type' => 'application/json' }, body.to_json]
    end
    stubs.post('https://api.speedy.bg/v1/pickup/terms') do |env|
      expect(JSON.parse(env.body)).to include('serviceId' => 505, 'startingDate' => '2026-10-07')
      [200, { 'Content-Type' => 'application/json' },
       { cutoffs: ['2026-10-07T16:00:00+03:00'] }.to_json]
    end
    stubs.post('https://api.speedy.bg/v1/track/bulk') do |env|
      expect(JSON.parse(env.body)).to include('lastProcessedFileId' => 12)
      [200, { 'Content-Type' => 'application/json' },
       { files: [{ id: 13, url: 'https://example.test/tracking/13.json' }] }.to_json]
    end

    barcode = client.barcode_information(parcel: { id: '700000001001' })
    expect(barcode.primary_shipment.type).to eq('FORWARD')
    expect(barcode.label_info.full_barcode).to eq('BRC')
    expect(client.pickup_terms(service_id: 505, starting_date: '2026-10-07').cutoffs).not_to be_empty
    expect(client.bulk_tracking_files(last_processed_file_id: 12).first.id).to eq(13)
  end

  it 'prints vouchers and returns raw document bytes' do
    stubs.post('https://api.speedy.bg/v1/print/voucher') do |env|
      expect(JSON.parse(env.body)).to include(
        'shipmentIds' => ['700000001'], 'format' => 'pdf'
      )
      [200, { 'Content-Type' => 'application/pdf' }, '%PDF-voucher']
    end

    expect(client.print_voucher(shipment_ids: ['700000001'], format: 'pdf')).to eq('%PDF-voucher')
  end

  it 'retrieves typed payouts' do
    stubs.post('https://api.speedy.bg/v1/payments') do |env|
      expect(JSON.parse(env.body)).to include(
        'fromDate' => '2026-10-01', 'toDate' => '2026-10-06', 'includeDetails' => true
      )
      body = {
        payouts: [{
          date: '2026-10-06', docId: 77, docType: 'POSTAL_MONEY_TRANSFER',
          paymentType: 'BANK', amount: 120.5, currency: 'BGN',
          details: [{ lineNo: 1, shipmentId: '700000001', amount: 120.5 }]
        }]
      }
      [200, { 'Content-Type' => 'application/json' }, body.to_json]
    end

    payout = client.payouts(
      from_date: '2026-10-01', to_date: '2026-10-06', include_details: true
    ).first

    expect(payout.doc_type).to eq('POSTAL_MONEY_TRANSFER')
    expect(payout.details.first.shipment_id).to eq('700000001')
  end

  it 'parses bulk location CSV responses into typed models' do
    stubs.post('https://api.speedy.bg/v1/location/country/csv') do
      csv = "100,Bulgaria,Bulgaria,BG,BGR,\"####\",false,1,BGN,1,\"ул.,бул.\",\"st.,blvd.\",ж.к.,qtr.,2\n"
      [200, { 'Content-Type' => 'text/csv' }, csv]
    end
    stubs.post('https://api.speedy.bg/v1/location/state/csv/100') do
      [200, { 'Content-Type' => 'text/csv' }, "SOF,Sofia,Sofia,SF,100\n"]
    end
    stubs.post('https://api.speedy.bg/v1/location/street/csv/100') do
      [200, { 'Content-Type' => 'text/csv' }, "1,68134,ул.,st.,Витоша,Vitosha,1\n"]
    end
    stubs.post('https://api.speedy.bg/v1/location/poi/csv/100') do
      [200, { 'Content-Type' => 'text/csv' },
       "2,68134,НДК,NDK,пл. България,Bulgaria Sq,23.31,42.68,сграда,building\n"]
    end
    stubs.post('https://api.speedy.bg/v1/location/postcode/csv/100') do
      [200, { 'Content-Type' => 'text/csv' }, "1000,68134\n"]
    end

    country = client.all_countries.first
    expect(country.street_types.first).to have_attributes(name: 'ул.', name_en: 'st.')
    expect(client.all_states(country_id: 100).first.country_id).to eq(100)
    expect(client.all_streets(country_id: 100).first.name).to eq('Витоша')
    expect(client.all_points_of_interest(country_id: 100).first.x).to eq(23.31)
    expect(client.all_postcodes(country_id: 100).first.postcode).to eq('1000')
  end
end
