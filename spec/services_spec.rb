# frozen_string_literal: true

RSpec.describe 'Speedy services' do
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:client) do
    Speedy::Client.new.tap do |client|
      client.username = 'speedy-user'
      client.password = 'speedy-pass'
      client.language = 'BG'
      client.adapter = [:test, stubs]
      client.setup_connection!
    end
  end

  it 'calculates delivery fees through /calculate' do
    stubs.post('https://api.speedy.bg/v1/calculate') do |env|
      body = JSON.parse(env.body)

      expect(body).to include(
        'userName' => 'speedy-user',
        'password' => 'speedy-pass',
        'language' => 'BG',
        'recipient' => hash_including('pickupOfficeId' => 123),
        'content' => hash_including('parcelsCount' => 1)
      )

      [
        200,
        { 'Content-Type' => 'application/json' },
        {
          calculations: [
            {
              serviceId: 505,
              price: { total: 7.5, currency: 'BGN', totalLocal: 7.5, currencyLocal: 'BGN' }
            }
          ]
        }.to_json
      ]
    end

    result = Speedy::Services::Calculation.new(client: client).calculate(
      recipient: { pickup_office_id: 123 },
      service: { service_ids: [505] },
      content: { parcels_count: 1, total_weight: 0.1 },
      payment: { courier_service_payer: 'SENDER' }
    ).to_a.first

    expect(result.service_id).to eq(505)
    expect(result.price.total).to eq(7.5)
  end

  it 'serializes schema-backed payload models to Speedy request keys' do
    recipient = Speedy::Models::Calculation::CalculationRecipient.new(
      pickup_office_id: 123,
      address_location: { site_name: 'София', post_code: '1000' }
    )
    service = Speedy::Models::Calculation::CalculationService.new(service_ids: [505])
    content = Speedy::Models::Calculation::CalculationContent.new(parcels_count: 1, total_weight: 0.1)
    payment = Speedy::Models::Shipments::ShipmentPayment.new(courier_service_payer: 'SENDER')
    sender = Speedy::Models::Calculation::CalculationSender.new(dropoff: false)

    expect(JSON.parse(recipient.to_json)).to include(
      'pickupOfficeId' => 123,
      'addressLocation' => hash_including('siteName' => 'София')
    )
    expect(JSON.parse(service.to_json)).to include('serviceIds' => [505])
    expect(JSON.parse(content.to_json)).to include('parcelsCount' => 1, 'totalWeight' => 0.1)
    expect(JSON.parse(payment.to_json)).to include('courierServicePayer' => 'SENDER')
    expect(JSON.parse(sender.to_json)).to include('dropoff' => false)
  end

  it 'creates shipments and exposes parcel ids for labels' do
    stubs.post('https://api.speedy.bg/v1/shipment') do |env|
      body = JSON.parse(env.body)

      expect(body).to include(
        'service' => hash_including('serviceId' => 505),
        'recipient' => hash_including('pickupOfficeId' => 123)
      )

      [
        200,
        { 'Content-Type' => 'application/json' },
        {
          id: '700000001',
          parcels: [{ id: '700000001001', seqNo: 1 }],
          price: { total: 7.5, currency: 'BGN' }
        }.to_json
      ]
    end

    shipment = Speedy::Services::Shipments::Shipment.new(client: client).create(
      service: { service_id: 505 },
      content: { parcels_count: 1, total_weight: 0.1 },
      payment: { courier_service_payer: 'SENDER' },
      recipient: { pickup_office_id: 123 }
    )

    expect(shipment.id).to eq('700000001')
    expect(shipment.parcels.first.id).to eq('700000001001')
  end

  it 'requests extended print labels through /print/extended' do
    stubs.post('https://api.speedy.bg/v1/print/extended') do |env|
      body = JSON.parse(env.body)

      expect(body).to include(
        'paperSize' => 'A6',
        'parcels' => [hash_including('parcelId' => hash_including('id' => '700000001001'))]
      )

      [
        200,
        { 'Content-Type' => 'application/json' },
        {
          data: 'base64-pdf',
          printLabelsInfo: [{ parcelId: '700000001001', fullBarcode: 'BRC' }]
        }.to_json
      ]
    end

    response = Speedy::Services::Print.new(client: client).create_pdf_extended(
      paper_size: 'A6',
      parcels: [{ parcel_id: { id: '700000001001' } }]
    )

    expect(response.data).to eq('base64-pdf')
    expect(response.print_labels_info.first.full_barcode).to eq('BRC')
  end

  it 'requests label metadata through /print/labelInfo' do
    stubs.post('https://api.speedy.bg/v1/print/labelInfo') do |env|
      body = JSON.parse(env.body)

      expect(body).to include(
        'parcels' => [hash_including('id' => '700000001001')]
      )

      [
        200,
        { 'Content-Type' => 'application/json' },
        { printLabelsInfo: [{ parcelId: '700000001001', fullBarcode: 'BRC' }] }.to_json
      ]
    end

    response = Speedy::Services::Print.new(client: client).label_info(
      parcels: [{ id: '700000001001' }]
    )

    expect(response.print_labels_info.first.parcel_id).to eq('700000001001')
    expect(response.print_labels_info.first.full_barcode).to eq('BRC')
  end

  it 'finds offices through /location/office' do
    stubs.post('https://api.speedy.bg/v1/location/office') do |env|
      body = JSON.parse(env.body)

      expect(body).to include('siteId' => 68_134, 'name' => 'център')

      [
        200,
        { 'Content-Type' => 'application/json' },
        {
          offices: [
            {
              id: 123,
              name: 'София Център',
              address: { siteName: 'София', postCode: '1000', addressLine1: 'бул. Витоша 1' },
              pickUpAllowed: true
            }
          ]
        }.to_json
      ]
    end

    office = Speedy::Services::Location::Office.new(client: client)
                                               .find(site_id: 68_134, name: 'център')
                                               .to_a
                                               .first

    expect(office.id).to eq(123)
    expect(office.address.site_name).to eq('София')
    expect(office.pick_up_allowed).to eq(true)
  end

  it 'finds sites before office lookup through /location/site' do
    stubs.post('https://api.speedy.bg/v1/location/site') do |env|
      body = JSON.parse(env.body)

      expect(body).to include(
        'countryId' => 100,
        'name' => 'София',
        'postCode' => '1000'
      )

      [
        200,
        { 'Content-Type' => 'application/json' },
        {
          sites: [
            {
              id: 68_134,
              countryId: 100,
              type: 'гр.',
              name: 'София',
              region: 'София',
              postCode: '1000'
            }
          ]
        }.to_json
      ]
    end

    site = Speedy::Services::Location::Site.new(client: client)
                                           .find(country_id: 100, name: 'София', post_code: '1000')
                                           .to_a
                                           .first

    expect(site.id).to eq(68_134)
    expect(site.name).to eq('София')
    expect(site.post_code).to eq('1000')
  end

  it 'loads all sites through /location/site/csv/{countryId}' do
    stubs.post('https://api.speedy.bg/v1/location/site/csv/100') do |env|
      body = JSON.parse(env.body)

      expect(body).to include(
        'userName' => 'speedy-user',
        'password' => 'speedy-pass',
        'language' => 'BG'
      )

      [
        200,
        { 'Content-Type' => 'text/csv' },
        "68134,100,0,гр.,gr.,София,SOFIA,Столична,STOLICHNA,София (столица),SOFIA CITY,1000,2,23.3219,42.6977,1111110,1,1\n"
      ]
    end

    site = Speedy::Services::Location::Site.new(client: client).all(country_id: 100).to_a.first

    expect(site.id).to eq(68_134)
    expect(site.name).to eq('София')
    expect(site.region).to eq('София (столица)')
  end

  it 'loads states through /location/state' do
    stubs.post('https://api.speedy.bg/v1/location/state') do |env|
      body = JSON.parse(env.body)

      expect(body).to include(
        'userName' => 'speedy-user',
        'password' => 'speedy-pass',
        'language' => 'BG',
        'countryId' => 100
      )

      [
        200,
        { 'Content-Type' => 'application/json' },
        {
          states: [
            {
              id: 'SOF',
              name: 'София (столица)',
              nameEn: 'Sofia City',
              stateAlpha: 'SF',
              countryId: 100
            }
          ]
        }.to_json
      ]
    end

    state = Speedy::Services::Location::State.new(client: client).all(country_id: 100).to_a.first

    expect(state.id).to eq('SOF')
    expect(state.name).to eq('София (столица)')
    expect(state.state_alpha).to eq('SF')
    expect(state.country_id).to eq(100)
  end

  it 'validates personal addresses through /validation/address' do
    stubs.post('https://api.speedy.bg/v1/validation/address') do |env|
      body = JSON.parse(env.body)

      expect(body).to include(
        'address' => hash_including(
          'siteName' => 'София',
          'postCode' => '1000',
          'streetName' => 'Витоша',
          'streetNo' => '1'
        )
      )

      [200, { 'Content-Type' => 'application/json' }, { valid: true }.to_json]
    end

    response = Speedy::Services::Validation::Address.new(client: client).validate_address(
      site_name: 'София',
      post_code: '1000',
      street_name: 'Витоша',
      street_no: '1'
    )

    expect(response).to be_valid
  end
end
