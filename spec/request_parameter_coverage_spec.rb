# frozen_string_literal: true

RSpec.describe 'Speedy request parameter coverage' do
  let(:response) { Struct.new(:body).new({}) }

  it 'forwards every shipment creation option' do
    service = Speedy::Services::Shipments::Shipment.allocate
    body = {
      service: { service_id: 505 },
      content: { parcels_count: 1 },
      payment: { courier_service_payer: 'SENDER' },
      sender: { client_id: 1 },
      recipient: { client_id: 2 },
      pending_shipment: true,
      shipment_note: 'note',
      ref1: 'ref-1',
      ref2: 'ref-2',
      consolidation_ref: 'batch-1',
      require_unsuccessful_delivery_sticker_image: true,
      id: 'client-generated-id'
    }

    expect_post(service, nil, body)
    service.create(**body)
  end

  it 'forwards every full-shipment update option' do
    service = Speedy::Services::Shipments::Shipment.allocate
    attributes = {
      service: { service_id: 505 }, content: { parcels_count: 1 },
      payment: { courier_service_payer: 'SENDER' }, sender: { client_id: 1 },
      recipient: { client_id: 2 }, pending_shipment: true, shipment_note: 'note',
      ref1: 'ref-1', ref2: 'ref-2', consolidation_ref: 'batch-1',
      require_unsuccessful_delivery_sticker_image: true
    }
    expect_post(service, 'update', { id: '7001' }.merge(attributes))

    service.update(id: '7001', **attributes)
  end

  it 'forwards every add-parcel and reference-search option' do
    service = Speedy::Services::Shipments::Shipment.allocate
    expect_post(service, 'add_parcel', {
                  shipment_id: '7001', parcel: { weight: 1.2 }, declared_value_amount: 50,
                  cod_amount: 40, cod_fiscal_receipt_items: [{ description: 'Artwork', amount: 40 }]
                })
    service.add_parcel(
      shipment_id: '7001', parcel: { weight: 1.2 }, declared_value_amount: 50,
      cod_amount: 40, cod_fiscal_receipt_items: [{ description: 'Artwork', amount: 40 }]
    )

    expect_post(service, 'search', {
                  ref: 'ORDER-1', search_in_ref: 1, shipments_only: true, include_returns: true,
                  from_date_time: '2026-10-01T00:00:00+03:00', to_date_time: '2026-10-11T23:59:59+03:00'
                }, body: { barcodes: [] })
    service.find_by_reference(
      ref: 'ORDER-1', search_in_ref: 1, shipments_only: true, include_returns: true,
      from_date_time: '2026-10-01T00:00:00+03:00', to_date_time: '2026-10-11T23:59:59+03:00'
    )
  end

  it 'forwards every pickup option' do
    service = Speedy::Services::Pickup.allocate
    create_body = {
      pickup_date_time: '2026-10-12T10:00:00+03:00', pickup_scope: 'EXPLICIT_SHIPMENT_ID_LIST',
      explicit_shipment_id_list: ['7001'], visit_end_time: '2026-10-12T12:00:00+03:00',
      contact_name: 'Test Contact', phone_number: '+359888000000', auto_adjust_pickup_date: true
    }
    expect_post(service, nil, create_body)
    service.create(**create_body)

    terms_body = {
      service_id: 505, starting_date: '2026-10-12', sender: { client_id: 1 },
      sender_has_payment: true
    }
    expect_post(service, 'terms', terms_body)
    service.terms(**terms_body)
  end

  it 'forwards every contact option' do
    service = Speedy::Services::Clients.allocate
    attributes = {
      external_contact_id: 'customer-1', secret_key: 'secret',
      phone1: { number: '+359888000001' }, phone2: { number: '+359888000002' },
      client_name: 'Customer', object_name: 'Studio', contact_name: 'Contact',
      email: 'customer@example.test', private_person: true,
      address: { site_id: 68_134, street_id: 1, street_no: '1' }
    }
    expect_post(service, 'contact', attributes, body: { client_id: 123 })

    service.create_contact(**attributes)
  end

  it 'forwards every print option' do
    service = Speedy::Services::Print.allocate
    print_body = {
      parcels: [{ parcel_id: { id: '7001' } }], format: 'pdf', paper_size: 'A6',
      printer_name: 'office-printer', dpi: 300, additional_waybill_sender_copy: true
    }
    expect_post(service, nil, print_body)
    service.create_pdf(**print_body)

    expect_post(service, 'extended', print_body)
    service.create_pdf_extended(**print_body)

    voucher_body = { shipment_ids: ['7001'], printer_name: 'office-printer', format: 'pdf', dpi: 300 }
    expect_post(service, 'voucher', voucher_body, body: 'PDF')
    service.voucher(**voucher_body)
  end

  it 'forwards every location filter option' do
    country = Speedy::Services::Location::Country.allocate
    expect_post(country, nil, { name: 'Bulgaria', iso_alpha2: 'BG', iso_alpha3: 'BGR' })
    country.find(name: 'Bulgaria', iso_alpha2: 'BG', iso_alpha3: 'BGR')

    site = Speedy::Services::Location::Site.allocate
    site_filters = {
      country_id: 100, name: 'Sofia', post_code: '1000', type: 'гр.',
      municipality: 'Столична', region: 'София-град'
    }
    expect_post(site, nil, site_filters)
    site.find(**site_filters)

    office = Speedy::Services::Location::Office.allocate
    office_filters = { country_id: 100, site_id: 68_134, site_name: 'Sofia', name: 'Center', limit: 10 }
    expect_post(office, nil, office_filters)
    office.find(**office_filters)

    nearest = {
      address: { site_id: 68_134 }, distance: 5_000, limit: 3,
      office_type: 'OFFICE', office_features: ['CARD_PAYMENT']
    }
    expect_post(office, 'nearest-offices', nearest)
    office.nearest(**nearest)
  end

  it 'forwards the remaining optional lookup and validation parameters' do
    street = Speedy::Services::Location::Street.allocate
    expect_post(street, nil, { site_id: 68_134, name: 'Vitosha', type: 'бул.' })
    street.find(site_id: 68_134, name: 'Vitosha', type: 'бул.')

    complex = Speedy::Services::Location::Complex.allocate
    expect_post(complex, nil, { site_id: 68_134, name: 'Lozenets', type: 'кв.' })
    complex.find(site_id: 68_134, name: 'Lozenets', type: 'кв.')

    validation = Speedy::Services::Validation::General.allocate
    expect_post(validation, 'postcode', { country_id: 100, post_code: '1000', site_id: 68_134 })
    validation.post_code(country_id: 100, post_code: '1000', site_id: 68_134)
  end

  it 'forwards every address and shipment validation option' do
    address_service = Speedy::Services::Validation::Address.allocate
    address = {
      site_id: 68_134, complex_id: 1, street_id: 2, poi_id: 3, block_no: '4',
      street_no: '5', entrance_no: 'A', return_site_center_if_no_address: true
    }
    expect_post(address_service, nil, { address: address })
    address_service.validate_address(address)

    validation = Speedy::Services::Validation::General.allocate
    body = {
      service: { service_id: 505 }, content: { parcels_count: 1 },
      payment: { courier_service_payer: 'SENDER' }, sender: { client_id: 1 },
      recipient: { client_id: 2 }, pending_shipment: true, shipment_note: 'note',
      ref1: 'ref-1', ref2: 'ref-2', consolidation_ref: 'batch-1',
      require_unsuccessful_delivery_sticker_image: true, id: 'client-generated-id'
    }
    expect_post(validation, 'shipment', body)
    validation.shipment(**body)
  end

  def expect_post(service, path, expected_body, body: {})
    arguments = path ? [path, { body: expected_body }] : [{ body: expected_body }]
    expect(service).to receive(:post).with(*arguments).and_return(Struct.new(:body).new(body))
    allow(service).to receive(:resource)
    allow(service).to receive(:collection)
  end
end
