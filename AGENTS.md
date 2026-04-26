# Repository Guidelines

## Project Structure & Module Organization

This repository publishes certificate helper files for `unisma.ac.id`.

- `generate.sh`: Bash script that refreshes certificate artifacts from the live domain.
- `cacert-unisma.ac.id.pem`: two-certificate bundle kept for Firefox and existing workflows.
- `cacert-unisma.ac.id.chromium.pem`: single-certificate PEM for Chromium import.

There is no source tree, package manager, or test directory. Treat the PEM files as release artifacts, not generated noise.

## Build, Test, and Development Commands

- `./generate.sh`: fetches the live certificate chain and regenerates both PEM files.
- `bash -n generate.sh`: checks Bash syntax without running network calls.
- `rg -c "BEGIN CERTIFICATE" cacert-unisma.ac.id.pem cacert-unisma.ac.id.chromium.pem`: verifies that the default bundle has 2 certificates and the Chromium file has 1.
- `openssl x509 -in cacert-unisma.ac.id.chromium.pem -noout -subject -issuer`: checks the single certificate identity.
- `git diff --check`: detects trailing whitespace and patch formatting issues.

`./generate.sh` needs network access and a local USERTrust RSA root certificate in the system trust store.

## Coding Style & Naming Conventions

Keep shell changes small and compatible with POSIX-like Linux environments. `generate.sh` is Bash, uses `set -euo pipefail`, and should keep quoted variables for paths and URLs. Match the existing indentation and avoid adding dependencies unless they are already standard command-line tools in this repo, such as `openssl`, `curl`, `awk`, and `sed`.

Certificate artifact names should stay explicit:

- Bundle file: `cacert-unisma.ac.id.pem`
- Chromium file: `cacert-unisma.ac.id.chromium.pem`

## Testing Guidelines

There is no automated test framework. Before submitting changes, run the syntax and certificate-count checks above. If you change certificate generation logic, run `./generate.sh` and verify both PEM files afterward. Do not change the two-file behavior unless the README and workflow expectations are updated together.
