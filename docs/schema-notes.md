# Speedy schema fidelity notes

The implementation is based on the JSON schemas distributed with Speedy's API
documentation. Those files describe payload shapes, but a schema file alone is
not evidence that a public HTTP route exists or remains enabled for every
account.

## Address search schemas without a route

The schema bundle contains `SearchAddressRequest`, `SearchAddressResponse`, and
`SearchAddress`. The request describes site, complex, street,
point-of-interest, and building-number inputs, while the response contains
address suggestions. However, the provided endpoint documentation does not
associate those types with an HTTP path.

No route is inferred from the Java package identifier or type name because an
incorrect route could create an apparently supported API that fails against
real accounts. Consequently, `Speedy::Client` does not expose address search.
It can be added compatibly when Speedy publishes an authoritative route and
request contract.

## Representation decisions

- JSON object responses with documented fields use typed `Speedy::Model`
  subclasses.
- Batch responses use `Speedy::Collection`, preserving top-level API errors.
- PDF and ZPL endpoints return binary strings; the gem does not decode or write
  them to disk.
- CSV nomenclature exports are parsed into the same model classes as JSON
  nomenclature results.
- Fields whose nested shape is not defined authoritatively remain arrays,
  hashes, or untyped model attributes rather than speculative classes.
- Undocumented fields are preserved in `Model#to_h`, so additive carrier
  changes do not discard information.

These notes describe documentation-derived support. They are not a substitute
for testing with the Speedy environment and permissions assigned to a specific
contract.
