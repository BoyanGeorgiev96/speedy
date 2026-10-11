# VCR contract testing

The opt-in contract suite records real read-only API responses and replays them
later with external network access disabled. Each endpoint has an independent
cassette. Public nomenclature contracts run with stable Bulgarian defaults;
account and shipment reads require the fixture identifiers described in
`.env.example` and are structurally sanitized before being written.

CI runs the committed recordings separately from the opt-in live suite:

```bash
SPEEDY_VCR_REPLAY=1 bundle exec rspec spec/recorded_contract_spec.rb
```

Replay does not load `.env` files or require carrier credentials. It uses
`record: :none`, rejects unmatched requests, and blocks network access even if
a cassette's record mode is overridden. Missing cassettes cannot be recorded by CI.

PDF printing has read-only contracts in `spec/live/printing_contract_spec.rb`.
They use existing demo parcel/shipment IDs and never pass `printerName`, so no
physical printing is requested. Raw PDF bodies and base64 PDF data are replaced
entirely before recording; metadata is structurally sanitized. Replays verify
the response envelope, document signature and metadata types, not PDF contents
or visual correctness. The retained PDF signature is only kept when the actual
document starts with `%PDF-`; unexpected opaque bodies are replaced with a
non-PDF marker so a failed request cannot become a passing PDF fixture.

To record these contracts, set `SPEEDY_CONTRACT_PARCEL_IDS` and
`SPEEDY_CONTRACT_SHIPMENT_IDS` to existing, printable demo fixtures, then run:

```bash
SPEEDY_LIVE_TESTS=1 bundle exec rspec spec/live/printing_contract_spec.rb
```

ZPL output is not covered by these PDF-specific contracts.

Offline request-shape specs exercise every explicit public keyword at least
once. Hash payloads and `**options` pass through generic serialization, so their
documented representative fields and model casting are tested without trying
every possible field combination. Live contracts use the smallest meaningful
payload for each server behavior; they are not a parameter-permutation suite.

## Coverage policy

| Endpoint kind | Contract approach |
| --- | --- |
| Public location and service nomenclatures | Recorded directly, one cassette per endpoint |
| Client, payout, calculation, shipment, tracking, and label-info reads | Recorded with dedicated demo fixtures and structural response redaction |
| Bulk CSV nomenclatures | Opt-in because Speedy may require account permission; one cassette per dataset |
| PDF labels, extended PDF labels, and PDF vouchers | Read-only fixtures; opaque document contents replaced entirely before recording |
| ZPL output | Offline coverage only; no live ZPL contract yet |
| Shipment, pickup, contact, and courier mutations | Excluded from the read-only suite; use the lifecycle pattern below |

## Mutating endpoints

VCR only records HTTP; it does not roll back the carrier. Projects that test
creation or updates against a real sandbox usually record a complete scenario:

1. create a uniquely identifiable shipment/contact/pickup in a dedicated demo
   account;
2. exercise the update, handover, or cancellation;
3. query and assert the resulting server state;
4. cancel or delete the fixture in an `ensure` cleanup block; and
5. record and verify the cleanup response in the same cassette.

Recording is manual. CI only replays reviewed cassettes and must never have
network access or carrier credentials. If cleanup is unavailable or unreliable,
use a provider-reset sandbox, disposable pre-provisioned fixtures, or an offline
request-shape test instead of a live mutation.

Before committing a recording, verify cleanup in the carrier UI, inspect the
diff, scan for credentials and personal data, and retain JSON types when
replacing identifiers. Never bulk re-record the entire suite automatically;
delete and refresh one cassette at a time.

## Reviewed mutation example

`spec/live/shipment_mutation_contract_spec.rb` implements the lifecycle above
for shipment creation. It creates a synthetic office-delivery shipment and
cancels it in an `ensure` block, then calls `shipment_info` to document that
Speedy retains the cancelled shipment as a historical record. It then tracks
the created parcel with its full operation history. The demo recording returns
an empty operation list immediately after cancellation, which the example
asserts. All four interactions are stored in
`speedy_api/shipment_create_cancel_and_verify.yml`; the generated shipment ID
is filtered.

The example requires an additional, deliberate opt-in:

```bash
SPEEDY_LIVE_TESTS=1 SPEEDY_MUTATING_LIVE_TESTS=1 \
  bundle exec rspec spec/live/shipment_mutation_contract_spec.rb
```

Before recording, verify that `SPEEDY_CONTRACT_OFFICE_ID` accepts service 505
and that the configured sender client may create shipments. A successful
`shipment/cancel` response is the authoritative cleanup confirmation. The
documented `shipment/info` response has no cancellation-status field, so the
final lookup verifies record retention and the generated identifier but cannot
independently prove cancellation. Tracking operation `128` means Canceled, but
the recorded uncollected shipment has no tracking operations after cancellation.
Neither an empty tracking history nor a retained shipment record independently
proves cancellation. This lifecycle relies on the documented successful cancel
response for cleanup confirmation. There is no documented dedicated cancellation
status field in the shipment information response.

## Mutation cleanup inventory

The classifications below describe the published API, not a guarantee that a
demo account accepts every payload. Cancellation is compensating cleanup: it
leaves a historical record and does not roll back all stored data.
Sources: [shipment, pickup, and contact API documentation](https://api.speedy.bg/api/docs/).

### Clear documented cleanup paths

| Endpoint | Scenario and cleanup | Recording status |
| --- | --- | --- |
| Create and cancel shipment | Create an uncollected shipment without requesting pickup; cancel it in `ensure` | Existing demo cassette confirms successful cancellation |
| Update shipment | Create a disposable shipment, replace its contents, query the changed contents, cancel | Recorded as `shipment_update_and_cancel` |
| Update shipment properties | Create a disposable shipment, change the `contents` property, query it, cancel | Recorded as `shipment_properties_and_cancel` |

All scenarios are in `spec/live/shipment_mutation_contract_spec.rb` and use
separate cassettes. Cleanup runs even if an operation or assertion fails after
creation returns an identifier. If creation times out before returning an ID,
automatic cleanup cannot identify the remote fixture; reconcile the account
before retrying. Cleanup failures fail the example and require manual review.
No pickup or handover is performed.

Existing cassettes replay as usual; do not delete them without planning another
disposable fixture. Read-back assertions check contents before cleanup. Successful
`shipment/cancel` remains the cancellation confirmation, not tracking history.

### Unavailable in the standard demo account

Adding parcels and finalizing a pending shipment require permission to create
with `pendingParcels`. The standard test account does not have this permission,
so these endpoints have offline request/model coverage only. The live lifecycle
and its capability flag were removed. Cancelling the parent shipment is the
documented cleanup approach for an authorized account, but that path has not
been verified in the demo environment.

### Suggested cleanup with uncertain effectiveness

| Endpoint | Possible approach | Uncertainty |
| --- | --- | --- |
| Request pickup | Cancel every associated disposable shipment, then ask the carrier to cancel/reset the pickup order | Cancelling shipments is not documented to cancel the courier visit or pickup order; no pickup cancellation endpoint is exposed |

This is a suggestion only and has no live mutation spec. Confirm order-level
cleanup with the carrier before recording it.

### No obvious API cleanup path

| Endpoint/action | Missing inverse |
| --- | --- |
| Create contact | No contact-delete endpoint; overwriting a contact would not remove it and could alter an existing account record |
| Handover to courier | No undo-handover endpoint; do not assume shipment cancellation reverses a registered handover |
| Handover to midway carrier | No undo for the registered external handover |
| Direct printing using `printerName` | Physical printing cannot be undone through the API; read-only print contracts omit this option |

These need carrier-managed reset or explicitly disposable fixtures. They remain
covered offline rather than by automatic live mutation scenarios.
