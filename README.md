# Speedy

Ruby client for the Speedy Bulgaria REST API. The structure mirrors the local `econt` gem: a Faraday client, resource classes for endpoint groups, and lightweight model objects with schema-backed attributes.

## Installation

Add the gem from this repository:

```ruby
gem "speedy", path: "../speedy"
```

## Configuration

```ruby
Speedy::Client.configure do |config|
  config.username = ENV.fetch("SPEEDY_USERNAME")
  config.password = ENV.fetch("SPEEDY_PASSWORD")
  config.language = "BG"
end
```

The default base URL is `https://api.speedy.bg/v1/`.

## Usage

Calculate a delivery fee:

```ruby
client = Speedy::Client.instance

calculations = client.calculate_delivery_fee(
  recipient: { pickup_office_id: 123 },
  service: { service_ids: [505] },
  content: { parcels_count: 1, total_weight: 0.1 },
  payment: { courier_service_payer: "SENDER" }
)

price = calculations.to_a.first.price
price.total
```

Create a shipment and print labels:

```ruby
shipment = client.create_shipment(
  service: { service_id: 505 },
  content: { parcels_count: 1, total_weight: 0.1, contents: "Artwork", package: "PACKAGE" },
  payment: { courier_service_payer: "SENDER" },
  recipient: { pickup_office_id: 123 }
)

label_pdf = client.print_labels(
  paper_size: "A6",
  parcels: shipment.parcels.map { |parcel| { parcel_id: { id: parcel.id } } }
)

label_pdf.data
```

Find a city/site and offices:

```ruby
site = client.find_sites(country_id: 100, name: "София", post_code: "1000").to_a.first
offices = client.find_offices(site_id: site.id)
```

Validate a personal delivery address:

```ruby
response = client.validate_address(
  site_name: "София",
  post_code: "1000",
  street_name: "Витоша",
  street_no: "1"
)

response.valid?
```

## Development

Run the test suite with:

```bash
bundle exec rspec
```
