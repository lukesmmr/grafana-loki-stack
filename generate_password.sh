#!/bin/bash
#
# generate_password.sh - Generate bcrypt hashed passwords for Caddy basic auth
#
# Usage:
#   ./generate_password.sh <username> <password>
#
# Example:
#   ./generate_password.sh admin my_secure_password

set -e

if [ $# -ne 2 ]; then
  echo "Usage: $0 <username> <password>"
  echo "Example: $0 admin my_secure_password"
  exit 1
fi

USERNAME=$1
PASSWORD=$2

# Check if docker is available
if ! command -v docker &> /dev/null; then
  echo "Error: docker is required but not installed."
  exit 1
fi

# Generate bcrypt hash using caddy
echo "Generating bcrypt hash for password..."
HASH=$(docker run --rm caddy:latest caddy hash-password --plaintext "$PASSWORD")

echo ""
echo "Add the following line to your Caddyfile in the basicauth block:"
echo "$USERNAME $HASH"
echo ""
echo "Example:"
echo "basicauth {"
echo "    $USERNAME $HASH"
echo "}"

exit 0 