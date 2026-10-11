# Speedy for Ruby

A community Ruby client for the Speedy Bulgaria REST API. Not affiliated with,
endorsed by, or maintained by Speedy AD. Supports Ruby 3.3, 3.4, and 4.0.

## Installation

```bash
bundle add speedy-bg
```

The package is `speedy-bg`; the namespace is `Speedy`. Bundler loads it
automatically, or use `require "speedy"` explicitly.

## Configuration

Configure once at application boot. The default URL is `https://api.speedy.bg/v1/`.

```ruby
Speedy::Client.configure do |config|
  config.username = ENV.fetch("SPEEDY_USERNAME")
  config.password = ENV.fetch("SPEEDY_PASSWORD")
  config.language = "BG"
  config.client_system_id = Integer(ENV["SPEEDY_CLIENT_SYSTEM_ID"], 10, exception: false)
  config.open_timeout = 10
  config.read_timeout = 30
  config.write_timeout = 30
end
```

For Rails, place configuration in `config/initializers/speedy.rb` and read
credentials from Rails credentials instead:

```ruby
Speedy::Client.configure do |config|
  config.username = Rails.application.credentials.dig(:speedy, :username)
  config.password = Rails.application.credentials.dig(:speedy, :password)
  config.client_system_id = Rails.application.credentials.dig(:speedy, :client_system_id)
  config.language = I18n.default_locale.to_s.upcase
end
```

`config.debug = true` logs headers and request/status lines, not bodies.
`config.debug_bodies = true` opts into body logging. Configured credentials are
always filtered, but bodies may expose customer data; protect those logs.

## Usage

Request arguments and response readers use `snake_case`; API `camelCase` and
acronyms are converted automatically.

```ruby
client = Speedy::Client.instance
site = client.find_sites(country_id: 100, name: "София").first
offices = client.find_offices(site_id: site.id)

calculations = client.calculate_delivery_fee(
  recipient: { pickup_office_id: offices.first.id },
  service: { service_ids: [505] },
  content: { parcels_count: 1, total_weight: 0.1 },
  payment: { courier_service_payer: "SENDER" }
)
price = calculations.first.price.total

tracking = client.track_shipments(
  parcels: [{ id: "700000001001" }], last_operation_only: true
)
latest_operation = tracking.first.operations.first
```

JSON endpoints return typed models or collections. Unknown response fields are
retained in models and `to_h`; missing documented fields return `nil`.
`print_labels_pdf` and `print_voucher` return raw PDF/ZPL bytes;
`print_labels` returns a typed extended-label response.

### Errors

HTTP and transport failures raise `Speedy::Error` or a subclass.
`Speedy::TransportError` covers `ConnectionError`, `TimeoutError`, and `SSLError`;
its `status` is `nil` and its `cause` retains the original exception.
Errors inside successful HTTP responses remain on models or collections:

```ruby
begin
  result = client.calculate_delivery_fee(**attributes)
  warn result.error.full_message if result.error?
rescue Speedy::Error => error
  warn "Speedy request failed: status=#{error.status.inspect}"
end
```

Inspect individual results for per-item errors too. Do not log submitted
shipment attributes or unsanitized API error messages containing customer data.
Transport messages are safe summaries; the original `cause` and `full_message`
may contain private data. Requests are not automatically retried, and a timeout
does not prove that a mutation failed. See the [error reference](docs/API.md#errors).

## API coverage

See the [method reference and examples](docs/API.md) for every public endpoint
method, its arguments, return type, and mutation warnings.

Calculation, shipment management, printing, tracking, courier services, pickup,
clients/contracts, payouts, location lookups and CSV exports, and validation are
implemented. Some operations require account permissions. Tracking-file URLs
are returned without downloading them.

See [response contracts](docs/RESPONSE_CONTRACTS.md) for endpoint coverage and
example-response tests, and [schema notes](docs/schema-notes.md) for unresolved
response shapes and the address-search schemas with no documented HTTP route.

## Development and contract tests

```bash
bundle install
bundle exec rake
bundle exec rbs -r date -I sig validate
bundle exec rake yard # Generates browsable documentation in doc/index.html
```

Normal tests do not contact Speedy. CI also replays committed VCR recordings
with recording and network access disabled, without loading `.env` files:

```bash
SPEEDY_VCR_REPLAY=1 bundle exec rspec spec/recorded_contract_spec.rb
```

For opt-in recording, copy
`.env.example` to `.env`, set test-account credentials and applicable
`SPEEDY_CONTRACT_*` values, then run:

```bash
SPEEDY_LIVE_TESTS=1 bundle exec rspec spec/live
```

Shipment mutations require `SPEEDY_MUTATING_LIVE_TESTS=1` as well and have explicit
cleanup. Printing tests use existing printable identifiers; documents are
replaced completely before recording. Review every cassette before committing.
See [VCR policy](docs/VCR.md) for gates, redaction, and cleanup limits.

## Versioning and support

This gem follows [Semantic Versioning 2.0.0](https://semver.org/). Before 1.0,
minor releases may break the public API. From 1.0, incompatible changes to
documented methods, arguments, models, return types, or errors require a major release.

Issues and focused fix PRs are welcome. Maintenance is best-effort, generally
reviewed on weekends; no response time or ongoing support is guaranteed.
See [contributing](CONTRIBUTING.md) and [security reporting](SECURITY.md).
MIT licensed; you are free to fork and adapt the client.
