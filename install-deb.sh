#!/bin/bash
set -euo pipefail

# install-deb.sh — install a Software Patterns CLI on Debian/Ubuntu.
#
# Usage:
#   curl -sSL https://github.com/softwarepatterns/homebrew-tap/raw/main/install-deb.sh | bash -s <cli-name>
#
# Example:
#   curl -sSL https://github.com/softwarepatterns/homebrew-tap/raw/main/install-deb.sh | bash -s jsonlog
#
# The <cli-name> must be one of: jsonlog, jsonmetrics, inbox-manager.

TAP_REPO="softwarepatterns/homebrew-tap"
GPG_KEY_URL="https://github.com/${TAP_REPO}/raw/main/public.gpg"

CLI_NAME="${1:-}"
if [[ -z "$CLI_NAME" ]]; then
    echo "Usage: $0 <cli-name>" >&2
    echo "Available CLIs: jsonlog, jsonmetrics, inbox-manager" >&2
    exit 1
fi

# Validate CLI name
case "$CLI_NAME" in
    jsonlog|jsonmetrics|inbox-manager) ;;
    *)
        echo "Error: unknown CLI '$CLI_NAME'" >&2
        echo "Available CLIs: jsonlog, jsonmetrics, inbox-manager" >&2
        exit 1
        ;;
esac

# Detect architecture
case "$(dpkg --print-architecture 2>/dev/null || uname -m)" in
    amd64|x86_64)   DEB_ARCH="amd64" ;;
    arm64|aarch64)  DEB_ARCH="arm64" ;;
    armhf|armv7l)   DEB_ARCH="armhf" ;;
    i386|i686)      DEB_ARCH="i386" ;;
    *)
        echo "Error: unsupported architecture" >&2
        exit 1
        ;;
esac

echo "Installing ${CLI_NAME} (${DEB_ARCH})..."

# Resolve latest release tag
LATEST_TAG=$(curl -fsSL "https://api.github.com/repos/${TAP_REPO}/releases/latest" \
    | grep '"tag_name":' \
    | sed -E 's/.*"([^"]+)".*/\1/')

if [[ -z "$LATEST_TAG" ]]; then
    echo "Error: could not resolve latest release" >&2
    exit 1
fi

VERSION_NUM="${LATEST_TAG#v}"
DEB_FILE="${CLI_NAME}_${VERSION_NUM}_${DEB_ARCH}.deb"
DEB_URL="https://github.com/${TAP_REPO}/releases/download/${LATEST_TAG}/${DEB_FILE}"
SHA256_URL="https://github.com/${TAP_REPO}/releases/download/${LATEST_TAG}/SHA256SUMS"

echo "Version: ${LATEST_TAG}"
echo "Package: ${DEB_FILE}"

# Download SHA256SUMS
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

curl -fsSL -o "${TMPDIR}/SHA256SUMS" "$SHA256_URL"

# Download .deb
curl -fsSL -o "${TMPDIR}/${DEB_FILE}" "$DEB_URL"

# Verify checksum
EXPECTED_SHA=$(grep "${DEB_FILE}" "${TMPDIR}/SHA256SUMS" | awk '{print $1}')
ACTUAL_SHA=$(sha256sum "${TMPDIR}/${DEB_FILE}" | awk '{print $1}')

if [[ "$EXPECTED_SHA" != "$ACTUAL_SHA" ]]; then
    echo "Error: SHA256 mismatch" >&2
    echo "  Expected: $EXPECTED_SHA" >&2
    echo "  Actual:   $ACTUAL_SHA" >&2
    exit 1
fi

echo "Checksum verified."

# Import GPG public key and verify signature (if gpg is available)
if command -v gpg >/dev/null 2>&1; then
    curl -fsSL "$GPG_KEY_URL" | gpg --import --batch 2>/dev/null || true
    if dpkg-sig --verify "${TMPDIR}/${DEB_FILE}" 2>/dev/null; then
        echo "Signature verified."
    fi
fi

# Install
sudo dpkg -i "${TMPDIR}/${DEB_FILE}"

echo ""
echo "${CLI_NAME} ${LATEST_TAG} installed."
echo "Run '${CLI_NAME} --help' to get started."
