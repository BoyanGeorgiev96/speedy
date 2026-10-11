# Method reference

All calls below use a configured `Speedy::Client`:

```ruby
require "speedy"
client = Speedy::Client.instance # Configure first; see the README.
```

Methods use snake_case keywords and readers; the client converts API camelCase.
A keyword ending in `:` is required; `: nil` is optional and usually omitted
from the outgoing payload. Signatures below expand the facade's `**args` to
show the keywords accepted by its service. `**options` and `**attributes`
forward additional endpoint fields, not arbitrary Ruby configuration.

Examples are independent illustrations, **not a script to execute in sequence**.
Replace resource IDs, dates, contacts and addresses with your account's fixtures.
Calls marked **mutation** change the selected remote environment; they are not
safe merely because their arguments are synthetic. Printing is download-only
unless `printer_name` is supplied. Account permissions may restrict any endpoint.

## Finding a method

- [Calculation](#calculation) — `calculate_delivery`.
- [Shipments](#shipments) — `create_shipment`, `shipment_info`, `update_shipment`, `update_shipment_properties`, `cancel_shipment`, `finalize_shipment`, `add_shipment_parcel`, `secondary_shipments`, `find_parcels_by_reference`, `hand_over_to_courier`, `hand_over_to_midway_carrier`, `barcode_information`.
- [Tracking](#tracking) — `track_shipments`, `bulk_tracking_files`.
- [Services and pickup](#services-and-pickup) — `courier_services`, `destination_services`, `request_pickup`, `pickup_terms`.
- [Printing](#printing) — `print_labels`, `print_labels_pdf`, `label_info`, `print_voucher`.
- [Clients and payments](#clients-and-payments) — `own_client_id`, `get_client`, `contract_clients`, `create_contact`, `contact_by_external_id`, `contract_info`, `payouts`.
- [Locations](#locations) — `find_sites`, `get_site`, `get_state`, `find_states`, `all_states`, `all_countries`, `all_sites`, `all_streets`, `all_complexes`, `all_blocks`, `all_points_of_interest`, `all_postcodes`, `find_countries`, `get_country`, `find_streets`, `get_street`, `find_complexes`, `get_complex`, `find_blocks`, `find_points_of_interest`, `get_point_of_interest`, `find_offices`, `get_office`, `nearest_offices`.
- [Validation](#validation) — `validate_address`, `validate_phone`, `validate_post_code`, `validate_shipment`.

`calculate_delivery_fee` is an alias of `calculate_delivery`.

## Payloads and results

Lookups provide country, site, office and service identifiers; don't guess them.
Use the [carrier payload reference](https://api.speedy.bg/api/docs/) for nested
required fields, enums, units and account-specific constraints. This reference
documents the Ruby interface; it does not promise that every payload will be
accepted by every account.

The following setup supplies the shared variables in the examples:

```ruby
country_id = 100
site_id = 68_134
office_id = 1 # Replace with a currently available office.
state_id = 1
street_id = 1
complex_id = 1
point_of_interest_id = 1
client_id = 123 # Use own_client_id or contract_clients.
shipment_id = "EXISTING_SHIPMENT_ID"
parcel_id = "EXISTING_PARCEL_ID"
external_contact_id = "EXISTING_EXTERNAL_CONTACT_ID"
external_contact_secret = ENV.fetch("SPEEDY_EXTERNAL_CONTACT_SECRET")
pickup_date_time = "2026-10-12T10:00:00" # Replace with a permitted future date.
address = { country_id: country_id, site_id: site_id, street_name: "Витоша", street_no: "1" }
sender = { client_id: client_id }
recipient = {
  private_person: true, client_name: "Synthetic Recipient",
  phone1: { number: "+359888000000" }, pickup_office_id: office_id
}
shipment_attributes = {
  sender: sender, recipient: recipient,
  service: { service_id: 505, auto_adjust_pickup_date: true },
  content: { parcels_count: 1, contents: "Artwork", total_weight: 0.1 },
  payment: { courier_service_payer: "SENDER" }
}
quote_attributes = shipment_attributes.merge(service: { service_ids: [505] })
```

Types below use `Collection<Model>` to mean an enumerable
`Speedy::Collection` containing typed model items. Models expose snake_case
readers and `to_h`. Collection errors and per-item errors must both be checked.
Raw document methods return bytes; extended printing returns base64 document
data in `data`, decoded with `result.data.unpack1("m0")`.

### Errors

Unsuccessful HTTP responses raise `Speedy::Error`. Network failures are wrapped
under `Speedy::TransportError`, which also inherits from `Speedy::Error`:

| Exception | Meaning |
| --- | --- |
| `Speedy::ConnectionError` | Connection could not be established or was interrupted |
| `Speedy::TimeoutError` | Connection, read or write timeout |
| `Speedy::SSLError` | TLS negotiation or certificate verification failure |

Transport errors have fixed, credential-free messages, `status: nil` and
`error: nil`. Their original exception is preserved as `cause`; its message,
response details and chained `full_message` may contain private data. Don't log
them without review. Parsing, configuration and programming errors are not
converted into transport errors.

No automatic retry occurs. A timeout or interrupted connection does not establish
whether a mutation succeeded; reconcile its state before retrying.
For typed results, successful HTTP responses may still contain a carrier error:

```ruby
begin
  result = client.calculate_delivery(**quote_attributes)
  if result.error?
    warn "Calculation rejected"
  else
    result.each do |item|
      next if item.error?
      puts item.price.total
    end
  end
rescue Speedy::TimeoutError
  warn "Request timed out; reconcile any mutation before retrying"
rescue Speedy::TransportError => error
  warn error.message # Fixed transport summary, not error.cause or full_message.
rescue Speedy::Error => error
  warn "Request failed: HTTP #{error.status.inspect}"
end
```

Scalar ID and barcode-list methods return only those values; they do not offer
`error?`. A missing ID may be `nil`. Avoid logging raw payloads, credentials,
document bytes or unsanitized carrier error messages.

## Calculation

### `calculate_delivery`

`client.calculate_delivery(recipient:, service:, content:, payment:, sender: nil, **options)`

Calculate available delivery prices without creating a shipment. Returns `Collection<Calculation::CalculationResult>`.

```ruby
client.calculate_delivery(**quote_attributes)
```

## Shipments

### `create_shipment`

`client.create_shipment(service:, content:, payment:, recipient:, sender: nil, **options)`

Create a shipment; retain its identifier for subsequent reads and cleanup. **Mutation.** Returns `Shipments::CreateShipmentResponse`.

```ruby
client.create_shipment(**shipment_attributes)
```

### `shipment_info`

`client.shipment_info(*shipment_ids)`

Retrieve shipment details; accepts individual IDs or an array. Returns `Collection<Shipments::Shipment>`.

```ruby
client.shipment_info(shipment_id)
```

### `update_shipment`

`client.update_shipment(id:, **attributes)`

Replace/update full shipment data using fields accepted by the shipment update endpoint. **Mutation.** Returns `Shipments::UpdateShipmentResponse`.

```ruby
client.update_shipment(id: shipment_id, **shipment_attributes)
```

### `update_shipment_properties`

`client.update_shipment_properties(id:, **properties)`

Update selected shipment properties; keywords are nested inside properties automatically. **Mutation.** Returns `Shipments::UpdateShipmentResponse`.

```ruby
client.update_shipment_properties(id: shipment_id, contents: "Artwork")
```

### `cancel_shipment`

`client.cancel_shipment(id:, comment: nil)`

Cancel an eligible shipment; inspect success? and error before treating cleanup as complete. **Mutation.** Returns `Response`.

```ruby
client.cancel_shipment(id: shipment_id, comment: "Synthetic test cleanup")
```

### `finalize_shipment`

`client.finalize_shipment(id:)`

Finalize a shipment that is awaiting parcel completion; requires applicable account permissions. **Mutation.** Returns `Shipments::CreateShipmentResponse`.

```ruby
client.finalize_shipment(id: shipment_id)
```

### `add_shipment_parcel`

`client.add_shipment_parcel(shipment_id:, parcel:, declared_value_amount: nil, cod_amount: nil, cod_fiscal_receipt_items: nil)`

Add a parcel to an eligible pending shipment; standard demo accounts may lack permission. **Mutation.** Returns `Shipments::CreatedShipmentParcel`.

```ruby
client.add_shipment_parcel(shipment_id: shipment_id, parcel: { weight: 0.1 })
```

### `secondary_shipments`

`client.secondary_shipments(shipment_id:, types: nil)`

List secondary shipments associated with a shipment. Returns `Collection<Shipments::SecondaryShipment>`.

```ruby
client.secondary_shipments(shipment_id: shipment_id)
```

### `find_parcels_by_reference`

`client.find_parcels_by_reference(ref:, search_in_ref:, shipments_only: nil, include_returns: nil, from_date_time: nil, to_date_time: nil)`

Find barcode strings by a shipment reference; search_in_ref selects reference fields. Returns `Array<String>`.

```ruby
client.find_parcels_by_reference(ref: "order-123", search_in_ref: 1)
```

### `hand_over_to_courier`

`client.hand_over_to_courier(parcels:)`

Register parcel handover to a courier; not a dry-run operation. **Mutation.** Returns `Response`.

```ruby
client.hand_over_to_courier(parcels: [{ id: parcel_id }])
```

### `hand_over_to_midway_carrier`

`client.hand_over_to_midway_carrier(parcels:)`

Register parcel handover to a midway carrier. **Mutation.** Returns `Response`.

```ruby
client.hand_over_to_midway_carrier(parcels: [{ id: parcel_id }])
```

### `barcode_information`

`client.barcode_information(parcel:)`

Retrieve barcode information for a parcel reference. Returns `Shipments::BarcodeInformation`.

```ruby
client.barcode_information(parcel: { id: parcel_id })
```

## Tracking

### `track_shipments`

`client.track_shipments(parcels:, last_operation_only: nil)`

Retrieve parcel tracking operations; true requests only the latest operation. Returns `Collection<Tracking::TrackedParcel>`.

```ruby
client.track_shipments(parcels: [{ id: parcel_id }], last_operation_only: true)
```

### `bulk_tracking_files`

`client.bulk_tracking_files(last_processed_file_id:)`

List available tracking files after a cursor; URLs are returned, not downloaded. Returns `Collection<Tracking::BulkTrackingDataFile>`.

```ruby
client.bulk_tracking_files(last_processed_file_id: 0)
```

## Services and pickup

### `courier_services`

`client.courier_services(date: nil)`

List courier services, optionally for an ISO date. Returns `Collection<Services::CourierService>`.

```ruby
client.courier_services
```

### `destination_services`

`client.destination_services(sender:, recipient:, date: nil)`

List services available for the supplied shipment parties. Returns `Collection<Services::ExtendedCourierService>`.

```ruby
client.destination_services(sender: sender, recipient: recipient)
```

### `request_pickup`

`client.request_pickup(pickup_date_time:, pickup_scope: nil, explicit_shipment_id_list: nil, visit_end_time: nil, contact_name: nil, phone_number: nil, auto_adjust_pickup_date: nil)`

Request a courier visit; auto_adjust_pickup_date allows server adjustment when supported. **Mutation.** Returns `Collection<Pickup::PickupOrder>`.

```ruby
client.request_pickup(pickup_date_time: pickup_date_time, explicit_shipment_id_list: [shipment_id])
```

### `pickup_terms`

`client.pickup_terms(service_id:, starting_date: nil, sender: nil, sender_has_payment: nil)`

Retrieve available pickup terms for a service and sender. Returns `Pickup::TermsResponse`.

```ruby
client.pickup_terms(service_id: 505)
```

## Printing

### `print_labels`

`client.print_labels(parcels:, format: nil, paper_size: nil, printer_name: nil, dpi: nil, additional_waybill_sender_copy: nil)`

Get extended labels with encoded document data and label metadata. **Physical printing possible when `printer_name` is provided.** Returns `Print::ExtendedPrintResponse`.

```ruby
client.print_labels(parcels: [{ parcel: { id: parcel_id } }], format: "pdf")
```

### `print_labels_pdf`

`client.print_labels_pdf(parcels:, format: nil, paper_size: nil, printer_name: nil, dpi: nil, additional_waybill_sender_copy: nil)`

Get raw label document bytes; despite its name, format may request ZPL. **Physical printing possible when `printer_name` is provided.** Returns `String`.

```ruby
client.print_labels_pdf(parcels: [{ parcel: { id: parcel_id } }], format: "pdf")
```

### `label_info`

`client.label_info(parcel: nil, parcels: nil)`

Retrieve label metadata. Returns `Print::LabelInfoResponse`.
Prefer `parcels:` with an array; it takes precedence over `parcel:`.
The `parcel:` shorthand accepts a single reference hash or an array of references.

```ruby
client.label_info(parcels: [{ id: parcel_id }])
```

### `print_voucher`

`client.print_voucher(shipment_ids:, printer_name: nil, format: nil, dpi: nil)`

Get raw voucher PDF/ZPL bytes for shipment IDs. **Physical printing possible when `printer_name` is provided.** Returns `String`.

```ruby
client.print_voucher(shipment_ids: [shipment_id], format: "pdf")
```

## Clients and payments

### `own_client_id`

`client.own_client_id`

Retrieve the authenticated client identifier. Returns `Integer, nil`.

```ruby
client.own_client_id
```

### `get_client`

`client.get_client(id)`

Retrieve a client by identifier. Returns `Clients::Client`.

```ruby
client.get_client(client_id)
```

### `contract_clients`

`client.contract_clients`

List clients available under the authenticated contract. Returns `Collection<Clients::Client>`.

```ruby
client.contract_clients
```

### `create_contact`

`client.create_contact(**attributes)`

Create a contact; forwards compacted contact attributes accepted by the API. **Mutation.** Returns `Integer, nil`.

```ruby
client.create_contact(client_name: "Synthetic Contact", private_person: true, phone1: { number: "+359888000000" }, address: address)
```

### `contact_by_external_id`

`client.contact_by_external_id(id:, secret_key:)`

Retrieve a contact using its external ID and secret; do not log the secret. Returns `Clients::Client`.

```ruby
client.contact_by_external_id(id: external_contact_id, secret_key: external_contact_secret)
```

### `contract_info`

`client.contract_info`

Retrieve contract information for the authenticated account. Returns `Clients::ContractInfo`.

```ruby
client.contract_info
```

### `payouts`

`client.payouts(from_date:, to_date:, include_details: nil)`

Retrieve payouts within an ISO-date interval; dates are cast to Ruby Date values where supported. Returns `Collection<Payments::Payout>`.

```ruby
client.payouts(from_date: "2026-10-01", to_date: "2026-10-10", include_details: true)
```

## Locations

### `find_sites`

`client.find_sites(country_id: nil, name: nil, post_code: nil, type: nil, municipality: nil, region: nil)`

Search cities/localities with optional filters. Returns `Collection<Location::Site>`.

```ruby
client.find_sites(country_id: 100, name: "София")
```

### `get_site`

`client.get_site(id)`

Get a site response envelope; the site is available through result.site. Returns `Location::GetSiteResponse`.

```ruby
client.get_site(site_id)
```

### `get_state`

`client.get_state(id)`

Retrieve a state by its identifier. Returns `Location::State`.

```ruby
client.get_state(state_id)
```

### `find_states`

`client.find_states(country_id: nil, name: nil)`

Search states with optional country and name filters. Returns `Collection<Location::State>`.

```ruby
client.find_states(country_id: country_id)
```

### `all_states`

`client.all_states(country_id:)`

Download and parse the state CSV dataset for a country. Returns `Collection<Location::State>`.

```ruby
client.all_states(country_id: country_id)
```

### `all_countries`

`client.all_countries`

Download and parse the country CSV dataset. Returns `Collection<Location::Country>`.

```ruby
client.all_countries
```

### `all_sites`

`client.all_sites(country_id:)`

Download and parse the sites CSV dataset for a country. Returns `Collection<Location::Site>`.

```ruby
client.all_sites(country_id: 100)
```

### `all_streets`

`client.all_streets(country_id:)`

Download and parse the streets CSV dataset for a country. Returns `Collection<Location::Street>`.

```ruby
client.all_streets(country_id: 100)
```

### `all_complexes`

`client.all_complexes(country_id:)`

Download and parse the complexes CSV dataset for a country. Returns `Collection<Location::Complex>`.

```ruby
client.all_complexes(country_id: 100)
```

### `all_blocks`

`client.all_blocks(country_id:)`

Download and parse the blocks CSV dataset for a country. Returns `Collection<Location::Block>`.

```ruby
client.all_blocks(country_id: 100)
```

### `all_points_of_interest`

`client.all_points_of_interest(country_id:)`

Download and parse the points of interest CSV dataset for a country. Returns `Collection<Location::PointOfInterest>`.

```ruby
client.all_points_of_interest(country_id: 100)
```

### `all_postcodes`

`client.all_postcodes(country_id:)`

Download and parse the postcodes CSV dataset for a country. Returns `Collection<Location::Postcode>`.

```ruby
client.all_postcodes(country_id: 100)
```

### `find_countries`

`client.find_countries(name: nil, iso_alpha2: nil, iso_alpha3: nil)`

Search countries by name or ISO code. Returns `Collection<Location::Country>`.

```ruby
client.find_countries(iso_alpha2: "BG")
```

### `get_country`

`client.get_country(id)`

Retrieve a country by identifier. Returns `Location::Country`.

```ruby
client.get_country(100)
```

### `find_streets`

`client.find_streets(site_id:, name: nil, type: nil)`

Search streets within a site. Returns `Collection<Location::Street>`.

```ruby
client.find_streets(site_id: site_id, name: "Витоша")
```

### `get_street`

`client.get_street(id)`

Retrieve a street by identifier. Returns `Location::Street`.

```ruby
client.get_street(street_id)
```

### `find_complexes`

`client.find_complexes(site_id:, name: nil, type: nil)`

Search complexes within a site. Returns `Collection<Location::Complex>`.

```ruby
client.find_complexes(site_id: site_id, name: "Витоша")
```

### `get_complex`

`client.get_complex(id)`

Retrieve a complex by identifier. Returns `Location::Complex`.

```ruby
client.get_complex(complex_id)
```

### `find_blocks`

`client.find_blocks(site_id:, name: nil)`

Search block/building numbers within a site. Returns `Collection<Location::Block>`.

```ruby
client.find_blocks(site_id: site_id, name: "1")
```

### `find_points_of_interest`

`client.find_points_of_interest(site_id:, name: nil)`

Search points of interest within a site. Returns `Collection<Location::PointOfInterest>`.

```ruby
client.find_points_of_interest(site_id: site_id)
```

### `get_point_of_interest`

`client.get_point_of_interest(id)`

Retrieve a point of interest by identifier. Returns `Location::PointOfInterest`.

```ruby
client.get_point_of_interest(point_of_interest_id)
```

### `find_offices`

`client.find_offices(country_id: nil, site_id: nil, site_name: nil, name: nil, limit: nil)`

Search offices and lockers with optional locality/name filters. Returns `Collection<Location::Office>`.

```ruby
client.find_offices(site_id: site_id, limit: 10)
```

### `get_office`

`client.get_office(id)`

Retrieve an office response envelope; the office is available through result.office. Returns `Location::GetOfficeResponse`.

```ruby
client.get_office(office_id)
```

### `nearest_offices`

`client.nearest_offices(address:, distance: nil, limit: nil, office_type: nil, office_features: nil)`

Find offices near an address; items contain office and distance metadata. Returns `Collection<Location::OfficeResult>`.

```ruby
client.nearest_offices(address: address, limit: 5)
```

## Validation

### `validate_address`

`client.validate_address(address)`

Validate a shipment address supplied as a hash or ShipmentAddress model. Returns `Validation::ValidationResponse`.

```ruby
client.validate_address(address)
```

### `validate_phone`

`client.validate_phone(number:, extension: nil)`

Validate a phone number, optionally including an extension. Returns `Validation::ValidationResponse`.

```ruby
client.validate_phone(number: "+359888000000")
```

### `validate_post_code`

`client.validate_post_code(country_id:, post_code:, site_id: nil)`

Validate a postcode against a country and optional site. Returns `Validation::ValidationResponse`.

```ruby
client.validate_post_code(country_id: 100, post_code: "1000")
```

### `validate_shipment`

`client.validate_shipment(service:, content:, payment:, recipient:, sender: nil, **options)`

Validate shipment attributes without creating a shipment. Returns `Validation::ValidationResponse`.

```ruby
client.validate_shipment(**shipment_attributes)
```

## Generated documentation

The source documents every endpoint shortcut with YARD signatures, parameter
notes, result types and examples. From a repository checkout, generate browsable
HTML without making API requests:

```bash
bundle exec rake yard
```

Open `doc/index.html`; generated `doc/` and `.yardoc` are ignored.
The Markdown reference is committed and packaged with the gem. A GitHub wiki is
not required. A hosted documentation site can be added separately without
changing where the source documentation lives.

For offline/live verification and mutation cleanup limits, see
[VCR policy](VCR.md). For response-shape exceptions, see
[response contracts](RESPONSE_CONTRACTS.md) and [schema notes](schema-notes.md).
