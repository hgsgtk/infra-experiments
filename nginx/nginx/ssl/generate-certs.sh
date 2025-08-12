#!/bin/bash

# Generate SSL certificates for nginx with client certificate verification
# This script creates a CA certificate and server certificates

set -e

echo "Generating SSL certificates..."

# Generate CA private key
echo "1. Generating CA private key..."
openssl genrsa -out ca.key 2048

# Generate CA certificate
echo "2. Generating CA certificate..."
openssl req -new -x509 -days 365 -key ca.key -out ca.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=CA"

# Generate server private key
echo "3. Generating server private key..."
openssl genrsa -out server.key 2048

# Generate server certificate signing request
echo "4. Generating server certificate signing request..."
openssl req -new -key server.key -out server.csr \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

# Sign server certificate with CA
echo "5. Signing server certificate with CA..."
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key \
    -CAcreateserial -out server.crt -days 365

# Clean up temporary files
echo "6. Cleaning up temporary files..."
rm -f server.csr

echo "SSL certificates generated successfully!"
echo "Files created:"
echo "  - ca.crt (CA certificate)"
echo "  - ca.key (CA private key)"
echo "  - server.crt (Server certificate)"
echo "  - server.key (Server private key)"
echo "  - ca.srl (CA serial number)"

echo ""
echo "Note: These are self-signed certificates for development/testing only."
echo "For production use, obtain certificates from a trusted Certificate Authority."
