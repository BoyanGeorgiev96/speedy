# frozen_string_literal: true

RSpec.describe 'Speedy validation API contract', :live do
  around do |example|
    VCR.use_cassette('speedy_api/postcode_validation') { example.run }
  end

  before do
    Speedy::Client.configure do |config|
      config.username = ENV.fetch('SPEEDY_USERNAME')
      config.password = ENV.fetch('SPEEDY_PASSWORD')
      client_system_id = ENV.fetch('SPEEDY_CLIENT_SYSTEM_ID', nil)
      config.client_system_id = Integer(client_system_id, 10, exception: false)
      config.base_url = ENV.fetch('SPEEDY_BASE_URL', 'https://api.speedy.bg/v1/')
    end
  end

  it 'validates the documented Sofia postcode without changing account state' do
    validation = Speedy::Client.instance.validate_post_code(
      country_id: 100,
      site_id: 68_134,
      post_code: '1000'
    )

    expect(validation).to be_a(Speedy::Models::Validation::ValidationResponse)
    expect(validation).to be_valid
  end
end
