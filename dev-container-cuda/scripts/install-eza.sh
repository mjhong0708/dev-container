#!/bin/bash
set -euo pipefail

API_URL="https://api.github.com/repos/eza-community/eza/releases/latest"
CURL_OPTS=(-fsSL --retry 3 --retry-delay 2)

VERSION=$(curl "${CURL_OPTS[@]}" "$API_URL" | grep -Po '"tag_name": "v\K[^"]*') || {
    echo "Failed to fetch latest eza version from $API_URL"
    exit 1
}
echo "Installing eza version $VERSION"

ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        DOWNLOAD_URL="https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz"
        ;;
    aarch64)
        DOWNLOAD_URL="https://github.com/eza-community/eza/releases/latest/download/eza_aarch64-unknown-linux-gnu.tar.gz"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

echo "Downloading eza from $DOWNLOAD_URL"
curl "${CURL_OPTS[@]}" -o eza.tar.gz "$DOWNLOAD_URL" || {
    echo "Failed to download eza archive"
    exit 1
}

tar -xzf eza.tar.gz
rm eza.tar.gz
sudo mv eza /usr/local/bin/eza
sudo chmod +x /usr/local/bin/eza
echo "eza version $VERSION installed successfully"
