# frozen_string_literal: true

RSpec.describe SpeedyVcrSanitizer do
  it 'redacts nested phone objects without changing their structure' do
    phones = { 'phones' => [{ 'number' => '+359888123456', 'extension' => 123 }] }
    expect(described_class.sanitize(phones)).to eq('phones' => [{ 'number' => '<REDACTED>', 'extension' => 0 }])
  end

  it 'redacts account response values while preserving JSON scalar types' do
    request = Struct.new(:uri).new('https://api.test/v1/client/contract')
    response = Struct.new(:body).new(
      JSON.generate(
        clientID: 123,
        clientName: 'Real Name',
        phones: ['+359888123456'],
        address: { streetName: 'Private Street', streetNo: '1' },
        content: { parcelsCount: 2, pendingParcels: true },
        active: true
      )
    )
    interaction = Struct.new(:request, :response).new(request, response)

    described_class.sanitize_response!(interaction)
    sanitized = JSON.parse(response.body)

    expect(sanitized).to include('clientID' => 0, 'clientName' => '<REDACTED>', 'active' => true)
    expect(sanitized.fetch('phones')).to eq(['<REDACTED>'])
    expect(sanitized.dig('address', 'streetName')).to eq('<REDACTED>')
    expect(sanitized.dig('address', 'streetNo')).to eq('<REDACTED>')
    expect(sanitized.fetch('content')).to include('parcelsCount' => 2, 'pendingParcels' => true)
  end

  it 'redacts UTF-8 JSON recorded with a binary encoding' do
    response_body = JSON.generate(
      clientID: 123,
      clientName: 'Тестов подател',
      email: 'sender@example.test',
      address: { siteName: 'София', postCode: '1000' }
    ).sub('123', '<SPEEDY_SENDER_CLIENT_ID>').dup.force_encoding(Encoding::ASCII_8BIT)
    interaction = interaction(
      uri: 'https://api.test/v1/shipment/info',
      request_body: '{}',
      response_body: response_body
    )

    described_class.sanitize_response!(interaction)
    sanitized = JSON.parse(interaction.response.body)

    expect(sanitized).to eq(
      'clientID' => 0,
      'clientName' => '<REDACTED>',
      'email' => '<REDACTED>',
      'address' => { 'siteName' => '<REDACTED>', 'postCode' => '<REDACTED>' }
    )
  end

  it 'uses one stable placeholder for a created shipment and its cleanup request' do
    create = interaction(
      uri: 'https://api.test/v1/shipment',
      request_body: '{}',
      response_body: JSON.generate(id: '700001234', clientName: 'Account Owner')
    )
    cancel = interaction(
      uri: 'https://api.test/v1/shipment/cancel',
      request_body: JSON.generate(shipmentId: '700001234'),
      response_body: '{}'
    )
    verification = interaction(
      uri: 'https://api.test/v1/shipment/info',
      request_body: JSON.generate(shipmentIds: ['700001234']),
      response_body: JSON.generate(shipments: [{ id: '700001234', error: { message: 'Not found' } }])
    )

    described_class.sanitize_mutation!(create)
    described_class.sanitize_mutation!(cancel)
    described_class.sanitize_mutation!(verification)

    expect(create.response.body).to include('<SPEEDY_CREATED_SHIPMENT_ID>')
    expect(create.response.body).not_to include('Account Owner')
    expect(cancel.request.body).to include('<SPEEDY_CREATED_SHIPMENT_ID>')
    expect(verification.request.body).to include('<SPEEDY_CREATED_SHIPMENT_ID>')
    expect(verification.response.body).to include('<SPEEDY_CREATED_SHIPMENT_ID>')
  end

  def interaction(uri:, request_body:, response_body:)
    message = Struct.new(:body)
    request = Struct.new(:uri, :body).new(uri, request_body)
    Struct.new(:request, :response).new(request, message.new(response_body))
  end

  it 'replaces entire binary label and voucher documents rather than leaking their contents' do
    %w[print print/voucher].each do |route|
      document = interaction(uri: "https://api.test/v1/#{route}", request_body: '{}',
                             response_body: "%PDF-1.7\nPrivate Name\xFF\x00".b)
      described_class.sanitize_response!(document)
      expect(document.response.body).to eq(described_class::REDACTED_PDF)
      expect(document.response.body).not_to include('Private Name')
    end
  end

  it 'replaces base64 print documents and redacts identifying label metadata' do
    document = interaction(uri: 'https://api.test/v1/print/extended', request_body: '{}',
                           response_body: JSON.generate(
                             data: ['%PDF-1.7 Private Name'].pack('m0'),
                             printLabelsInfo: [{ fullBarcode: 'secret-barcode', officeName: 'Private Office' }]
                           ))
    described_class.sanitize_response!(document)
    parsed = JSON.parse(document.response.body)
    expect(parsed.fetch('data').unpack1('m0')).to eq(described_class::REDACTED_PDF)
    expect(parsed.fetch('printLabelsInfo').first)
      .to eq('fullBarcode' => '<REDACTED>', 'officeName' => '<REDACTED>')
  end

  it 'fails closed for unexpected opaque document bodies without inventing PDF success' do
    document = interaction(uri: 'https://api.test/v1/print', request_body: '{}',
                           response_body: 'Private Name: malformed document')
    described_class.sanitize_response!(document)
    expect(document.response.body).to eq('<REDACTED_DOCUMENT>')
  end

  it 'preserves structured printing errors without converting them to PDF success' do
    document = interaction(uri: 'https://api.test/v1/print', request_body: '{}',
                           response_body: JSON.generate(error: { code: 100, message: 'Cannot print' }))
    described_class.sanitize_response!(document)
    expect(JSON.parse(document.response.body)).to eq('error' => { 'code' => 100, 'message' => 'Cannot print' })
  end
end
