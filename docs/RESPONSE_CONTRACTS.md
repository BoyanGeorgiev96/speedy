# Offline response contracts

`spec/response_property_examples_spec.rb` exercises every endpoint shortcut in
`Speedy::ClientResources` through a real configured client and a local Faraday
test adapter. It makes no HTTP requests. A coverage assertion fails when a new
public shortcut lacks a scenario; the calculation alias is listed explicitly.

The checked-in `spec/fixtures/responses/*.json` files contain one synthetic
example per response type, assembled from the official schema snapshot. They exercise optional
properties as well as the required ones. They are examples of response shapes,
not successful live recordings or evidence that every optional property occurs
together. Tests never load the gitignored `schema/` directory. The authoritative
reference is the [Speedy API documentation](https://api.speedy.bg/api/docs/).

The recursive `expect_response_properties(actual, raw)` assertion derives a
snake_case accessor independently from each original JSON key. It calls the
accessor and compares every leaf with the original response value, including
false, zero, explicit null, nested models and every array item. The three
explicit dictionary structures (`details`, `detailsLocal`, and
`externalCarrierParcelNumbersDetails`) use hash-key lookup, not dot readers;
dictionaries retain the client's existing snake_case normalization
of keys, and typed dictionary values are checked using their model accessors.
Unknown scalar attributes are also checked. Regression examples prove the
helper rejects absent accessors, dropped nested fields, incorrect values and
raw hashes in place of typed nested models.

There are two explicit conversions rather than consulting the model's field
definitions to manufacture expected values: documented Date accessors use
`Date.parse`, and a null parcel array becomes `[]` under the existing array
casting contract. CSV cases independently list every expected column and its
typed value. Scalar client IDs and barcode lists are compared directly; empty
success objects have no leaf properties. PDF methods compare unchanged bytes,
including binary data. Error objects are checked through both a resource and a
collection response.

## Schema limitations and discrepancies

- Extended print's schema describes `data` as an integer array, while the
  documentation describes a base64 string. Its example follows the documented
  JSON representation.
- External carrier parcel details are documented as a map, so populated maps
  now return typed values instead of being treated as arrays. Empty arrays
  seen in recordings remain readable for compatibility.
- Calculation additional services, courier-service allowances and office
  maximum parcel dimensions now expose schema-backed nested model readers.
- The schema's unresolved `OfficeRoutingInformation` reference is covered by
  the documentation's [RoutingInformation definition, section 3.34](https://api.speedy.bg/api/docs/#href-routing-information)
  and [Tour definition, section 3.34.1](https://api.speedy.bg/api/docs/#href-routing-information-tour).
  Office responses now expose typed routing and tour readers; all three office
  JSON examples contain populated routing data checked recursively.
- `WorkDayType` and `DeliveryLimitViolationAutoAdjustment` have unresolved references in the
  available schema snapshot. Their example values are null; no nested contract
  is invented for these structures.
- These examples test parsing and accessor fidelity. Existing VCR/live specs
  remain the evidence for actual server behavior and account restrictions.
