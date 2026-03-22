#!/usr/bin/env bash
set -euo pipefail

# Install Terraform from official releases without apt to avoid external repo GPG issues.
TERRAFORM_VERSION="${TERRAFORM_VERSION:-1.8.5}"
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64) ARCH="amd64" ;;
  aarch64|arm64) ARCH="arm64" ;;
  *)
    echo "Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Installing Terraform ${TERRAFORM_VERSION} (${ARCH})"
curl -fsSL "$URL" -o "$TMP_DIR/terraform.zip"
unzip -q "$TMP_DIR/terraform.zip" -d "$TMP_DIR"
chmod +x "$TMP_DIR/terraform"

if command -v sudo >/dev/null 2>&1; then
  sudo install -m 0755 "$TMP_DIR/terraform" /usr/local/bin/terraform
else
  mkdir -p "$HOME/.local/bin"
  install -m 0755 "$TMP_DIR/terraform" "$HOME/.local/bin/terraform"
fi

echo "Terraform installed: $(terraform version | head -n 1)"
