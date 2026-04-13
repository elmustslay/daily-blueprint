#!/bin/bash
set -e
# Create self signed cert
openssl req -x509 -newkey rsa:2048 -nodes -keyout key.pem -out cert.pem -days 365 -subj "/CN=MyDummyCert"
openssl pkcs12 -export -out cert.p12 -inkey key.pem -in cert.pem -passout pass:test
# Setup Keychain
# Ignore if keychain exists
security delete-keychain temp.keychain || true
security create-keychain -p "test" temp.keychain
security list-keychains -d user -s temp.keychain ~/Library/Keychains/login.keychain-db
security unlock-keychain -p "test" temp.keychain
security import cert.p12 -k temp.keychain -P "test" -A
security set-key-partition-list -S apple-tool:,apple: -s -k "test" temp.keychain
echo "Setup complete. Keychains:"
security list-keychains
