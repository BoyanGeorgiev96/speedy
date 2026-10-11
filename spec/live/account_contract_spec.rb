# frozen_string_literal: true

RSpec.describe 'Speedy read-only account contracts', :live do
  around do |example|
    VCR.use_cassette(example.metadata.fetch(:cassette)) { example.run }
  end

  before do
    Speedy::Client.configure do |config|
      config.username = ENV.fetch('SPEEDY_USERNAME')
      config.password = ENV.fetch('SPEEDY_PASSWORD')
      config.client_system_id = Integer(ENV.fetch('SPEEDY_CLIENT_SYSTEM_ID', nil), 10, exception: false)
      config.base_url = ENV.fetch('SPEEDY_BASE_URL', 'https://api.speedy.bg/v1/')
    end
  end

  it 'loads the authenticated client id', cassette: 'speedy_api/own_client_id' do
    expect(Speedy::Client.instance.own_client_id).to be_a(Integer)
  end

  it 'loads sanitized contract clients', cassette: 'speedy_api/contract_clients' do
    clients = Speedy::Client.instance.contract_clients

    expect(clients).not_to be_empty
    expect(clients).to all(be_a(Speedy::Models::Clients::Client))
  end

  it 'loads sanitized contract capabilities', cassette: 'speedy_api/contract_info' do
    contract = Speedy::Client.instance.contract_info

    expect(contract).to be_a(Speedy::Models::Clients::ContractInfo)
  end

  it 'loads a client by configured id', cassette: 'speedy_api/client_detail' do
    client_id = Integer(ENV.fetch('SPEEDY_SENDER_CLIENT_ID', nil), 10, exception: false)
    skip 'Set SPEEDY_SENDER_CLIENT_ID to record this read-only contract' unless client_id

    client = Speedy::Client.instance.get_client(client_id)

    expect(client).to be_a(Speedy::Models::Clients::Client)
  end

  it 'loads an external contact when fixture credentials are configured', cassette: 'speedy_api/external_contact' do
    id = ENV.fetch('SPEEDY_CONTRACT_EXTERNAL_CONTACT_ID', '')
    secret = ENV.fetch('SPEEDY_CONTRACT_EXTERNAL_CONTACT_SECRET', '')
    skip 'Set SPEEDY_CONTRACT_EXTERNAL_CONTACT_ID and SPEEDY_CONTRACT_EXTERNAL_CONTACT_SECRET' if
      id.empty? || secret.empty?

    contact = Speedy::Client.instance.contact_by_external_id(id: id, secret_key: secret)

    expect(contact).to be_a(Speedy::Models::Clients::Client)
  end

  it 'loads sanitized payout information for the contract date', cassette: 'speedy_api/payouts' do
    payouts = Speedy::Client.instance.payouts(
      from_date: contract_date,
      to_date: contract_date,
      include_details: true
    )

    expect(payouts).to all(be_a(Speedy::Models::Payments::Payout))
  end

  it 'loads bulk tracking file metadata', cassette: 'speedy_api/bulk_tracking_files' do
    files = Speedy::Client.instance.bulk_tracking_files(last_processed_file_id: 0)

    expect(files).to all(be_a(Speedy::Models::Tracking::BulkTrackingDataFile))
  end

  def contract_date
    ENV.fetch('SPEEDY_CONTRACT_DATE', '').then do |value|
      value.empty? ? Date.today.iso8601 : value
    end
  end
end
