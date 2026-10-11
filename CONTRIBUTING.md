# Contributing

Thanks for helping improve `speedy-bg`. This is an independent community
project and is not supported by Speedy AD.

## Support scope

Use GitHub issues for reproducible bugs, documentation corrections, and focused
feature proposals. Include the gem version, Ruby version, endpoint name,
expected behavior, actual behavior, and a minimal sanitized example. Never post
credentials, unredacted request or response bodies, customer details, shipment
numbers, or contract-specific data.

Maintenance is best-effort and generally reviewed on weekends. There is no
guaranteed response time, endpoint coverage, compatibility with undocumented
carrier behavior, or commercial support. Pull requests for fixes are welcome.
Users are also free to fork the MIT-licensed project and maintain behavior that
is outside this project's scope.

Security reports must follow [SECURITY.md](SECURITY.md), not the public issue
tracker.

## Development

Use a currently supported Ruby version, then install dependencies and run:

```bash
bundle install
bundle exec rake
bundle exec rbs validate
```

Do not make live carrier requests in the normal test suite. Add deterministic
Faraday test-adapter examples for request serialization, response casting, and
errors. Contract recordings are opt-in, must use read-only operations unless a
cleanup plan has been agreed, and must be reviewed for authentication and
personal data before committing them.

## Pull requests

- Keep changes focused and explain the public API impact.
- Add or update tests for behavior changes.
- Update the README, RBS declarations, and schema notes when public behavior
  changes.
- Preserve Ruby 3.3, 3.4, and 4.0 compatibility.
- Confirm `bundle exec rake`, `bundle exec rbs validate`, and the package smoke
  test pass.

By contributing, you agree that your contribution is licensed under the MIT
License included in this repository.

## Releasing

The `Release to RubyGems` workflow is manual and its `publish` confirmation is
disabled by default, so it never runs during ordinary CI. To release, select
the existing `vVERSION` tag matching the gemspec when dispatching the workflow
and enable the confirmation. Dispatching from a branch or a mismatched tag
fails the version check. It uses RubyGems Trusted Publishing and does not read a
long-lived API key from repository secrets.

Before the first release, the owner must configure a pending trusted publisher
for the `speedy-bg` gem on RubyGems.org. It must identify this repository,
`.github/workflows/release.yml`, and the GitHub `release` environment. The
repository variable `RUBYGEMS_TRUSTED_PUBLISHING_ENABLED` must then be set to
`true`. Until both the publisher and this gate are configured, the release job
is skipped safely. Normal CI also checks that any pushed `v*` tag exactly
matches the gemspec version.
