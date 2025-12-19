#!/bin/bash
set -euo pipefail

API_URL="https://api.github.com/repos/casey/just/releases/latest"
CURL_OPTS=(-fsSL --retry 3 --retry-delay 2)

# Just uses tag names without a "v" prefix
VERSION=$(curl "${CURL_OPTS[@]}" "$API_URL" | grep -Po '"tag_name": "\K[^"]*') || {
    echo "Failed to fetch latest just version from $API_URL"
    exit 1
}
echo "Installing just version $VERSION"

ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        DOWNLOAD_URL="https://github.com/casey/just/releases/latest/download/just-${VERSION}-x86_64-unknown-linux-musl.tar.gz"
        ;;
    aarch64)
        DOWNLOAD_URL="https://github.com/casey/just/releases/latest/download/just-${VERSION}-aarch64-unknown-linux-musl.tar.gz"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

echo "Downloading just from $DOWNLOAD_URL"
curl "${CURL_OPTS[@]}" -o just.tar.gz "$DOWNLOAD_URL" || {
    echo "Failed to download just archive"
    exit 1
}

tar -xzf just.tar.gz just
rm just.tar.gz
sudo mv just /usr/local/bin/just
sudo chmod +x /usr/local/bin/just
echo "just version $VERSION installed successfully"
