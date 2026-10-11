# frozen_string_literal: true

RSpec.describe 'Speedy read-only printing contracts', :live do
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

  it 'downloads a PDF label without sending it to a printer', cassette: 'speedy_api/print_labels_pdf' do
    parcels = configured_ids('SPEEDY_CONTRACT_PARCEL_IDS').map { |id| { parcel: { id: id } } }
    pdf = Speedy::Client.instance.print_labels_pdf(parcels: parcels, format: 'pdf', paper_size: 'A4')

    expect(pdf).to be_a(String)
    expect(pdf.b).to start_with('%PDF-'.b)
  end

  it 'downloads base64 PDF labels and typed metadata', cassette: 'speedy_api/print_labels_extended' do
    parcels = configured_ids('SPEEDY_CONTRACT_PARCEL_IDS').map { |id| { parcel: { id: id } } }
    result = Speedy::Client.instance.print_labels(parcels: parcels, format: 'pdf', paper_size: 'A4')

    expect(result).to be_a(Speedy::Models::Print::ExtendedPrintResponse)
    expect(result).not_to be_error
    expect(result.data.unpack1('m0').b).to start_with('%PDF-'.b)
    expect(result.print_labels_info).not_to be_empty
    expect(result.print_labels_info).to all(be_a(Speedy::Models::Print::LabelInfo))
  end

  it 'downloads a PDF voucher without sending it to a printer', cassette: 'speedy_api/print_voucher' do
    pdf = Speedy::Client.instance.print_voucher(
      shipment_ids: configured_ids('SPEEDY_CONTRACT_SHIPMENT_IDS'), format: 'pdf'
    )

    expect(pdf).to be_a(String)
    expect(pdf.b).to start_with('%PDF-'.b)
  end

  def configured_ids(key)
    values = ENV.fetch(key, '').split(',').map(&:strip).reject(&:empty?)
    skip "Set #{key} to record this read-only contract using an existing demo shipment" if values.empty?

    values
  end
end
