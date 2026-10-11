# Security policy

## Supported versions

Until a stable release exists, security fixes are made on the latest released
version and the default branch only. After 1.0, the latest minor line will be
the supported line unless a release announcement says otherwise.

## Reporting a vulnerability

Do not open a public issue for suspected vulnerabilities or exposed secrets.
Use GitHub's private vulnerability reporting for this repository. If that
facility is unavailable, contact the maintainer privately through the contact
details on the repository owner's GitHub profile.

Include a description, affected versions, reproduction steps, impact, and any
suggested mitigation. Remove real credentials and customer or shipment data.
Reports are handled on a best-effort basis; the project cannot promise a
response or remediation deadline.

## Integration responsibilities

The gem sends carrier credentials and may process names, phone numbers,
addresses, shipment contents, and financial information. Applications must
protect credentials, restrict log access, choose appropriate retention, and
comply with applicable privacy requirements. Debug response bodies are disabled
by default. Enabling body logging is an explicit application decision and
should not be used in production. Configured credentials remain filtered even
when body logging is enabled.
