#!/usr/bin/env bash
set -euo pipefail

DOMAIN="${1:-unisma.ac.id}"
OUT="cacert-unisma.ac.id.pem"
CHROMIUM_OUT="cacert-unisma.ac.id.chromium.pem"
TMPDIR="$(mktemp -d)"

cleanup() {
	rm -rf "$TMPDIR"
}
trap cleanup EXIT

ROOT_CA=""
for file in \
	/etc/pki/ca-trust/extracted/pem/directory-hash/USERTrust_RSA_Certification_Authority.pem \
	/etc/ssl/certs/USERTrust_RSA_Certification_Authority.pem
do
	if [ -f "$file" ]; then
		ROOT_CA="$file"
		break
	fi
done

if [ -z "$ROOT_CA" ]; then
	echo "USERTrust RSA root CA was not found in the system trust store." >&2
	exit 1
fi

echo "Fetching certificate from $DOMAIN..."
openssl s_client \
	-showcerts \
	-servername "$DOMAIN" \
	-connect "$DOMAIN:443" \
	</dev/null \
	2>/dev/null \
| awk '
      /-----BEGIN CERTIFICATE-----/ && !done { found = 1; print_cert = 1 }
      print_cert && !done { print }
      /-----END CERTIFICATE-----/ && print_cert { done = 1; print_cert = 0 }
      END { if (!found) exit 1 }
    ' > "$TMPDIR/leaf.pem"

INTERMEDIATE_URL="$(
  openssl x509 -in "$TMPDIR/leaf.pem" -noout -text \
    | sed -n 's/^.*CA Issuers - URI://p' \
    | head -n 1
)"

if [ -z "$INTERMEDIATE_URL" ]; then
	echo "Intermediate CA URL was not found in the certificate." >&2
	exit 1
fi

echo "Downloading intermediate CA..."
curl -L --fail --silent --show-error \
	-o "$TMPDIR/intermediate.crt" \
	"$INTERMEDIATE_URL"

if ! openssl x509 -inform DER -in "$TMPDIR/intermediate.crt" -out "$TMPDIR/intermediate.pem" 2>/dev/null; then
	openssl x509 -in "$TMPDIR/intermediate.crt" -out "$TMPDIR/intermediate.pem"
fi

cp "$TMPDIR/intermediate.pem" "$CHROMIUM_OUT"

{
	cat "$TMPDIR/intermediate.pem"
	printf '\n'
	cat "$ROOT_CA"
} > "$OUT"

chmod 0644 "$OUT"
chmod 0644 "$CHROMIUM_OUT"

echo "Verifying CA bundle with openssl..."
openssl verify -CAfile "$OUT" "$TMPDIR/leaf.pem" >/dev/null
echo "OpenSSL file verification: OK"

openssl s_client \
	-CAfile "$OUT" \
	-verify_return_error \
	-servername "$DOMAIN" \
	-connect "$DOMAIN:443" \
	-brief \
	</dev/null \
	> "$TMPDIR/openssl-live.txt" \
	2>&1

if ! grep -q "Verification: OK" "$TMPDIR/openssl-live.txt"; then
	cat "$TMPDIR/openssl-live.txt" >&2
	echo "OpenSSL live TLS verification failed." >&2
	exit 1
fi

echo "OpenSSL live TLS verification: OK"

echo "Successfully created $OUT"
echo "Successfully created $CHROMIUM_OUT"
echo "These files can be used for unisma.ac.id and subdomains that use the same Sectigo/USERTrust chain."
