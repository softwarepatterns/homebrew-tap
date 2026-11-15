#!/usr/bin/env bash
# install-deb.sh — verified Linux installer for Software Patterns products.
#
# Usage: install-deb.sh <product> [version]
#   product  e.g. forgejo
#   version  bare semver (e.g. 0.2.0); default: the tap's latest release
#
# Pipeline: download SHA256SUMS + its GPG signature + the .deb for this
# machine's architecture from the tap's GitHub release, verify SHA256SUMS
# against the public.gpg in this repo (fetched fresh), verify the package's
# sha256 line, then install with apt (dependencies resolved). Nothing is
# installed until every check passes.
#
# Requirements: curl, gpg, sha256sum; sudo for the apt step (unless root).

set -euo pipefail

PRODUCT="${1:?usage: install-deb.sh <product> [version]}"
VERSION="${2:-}"

TAP_ORG=softwarepatterns
TAP_REPO=homebrew-tap
RAW="https://raw.githubusercontent.com/${TAP_ORG}/${TAP_REPO}/main"
RELEASES="https://github.com/${TAP_ORG}/${TAP_REPO}/releases/download"
API="https://api.github.com/repos/${TAP_ORG}/${TAP_REPO}"

# Architecture from the kernel name; refuse anything else loudly.
case "$(uname -m)" in
    x86_64)        ARCH=amd64 ;;
    aarch64|arm64) ARCH=arm64 ;;
    *) echo "unsupported architecture: $(uname -m)" >&2; exit 2 ;;
esac

# The release tag carries the product prefix (forgejo/v0.2.0); asset names
# and checksums carry only the bare semver.
if [ -z "${VERSION}" ]; then
    TAG="$(curl -fsSL "${API}/releases/latest" \
        | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -1)"
    VERSION="${TAG#${PRODUCT}/v}"
    [ -n "${VERSION}" ] || { echo "could not resolve the latest ${PRODUCT} release" >&2; exit 1; }
else
    TAG="${PRODUCT}/v${VERSION}"
fi

echo "== ${PRODUCT} ${VERSION} (${ARCH})"

WORK="$(mktemp -d)"
trap 'rm -rf "${WORK}"' EXIT
cd "${WORK}"

echo "== fetch checksums, signature, and package"
curl -fsSL -o public.gpg "${RAW}/public.gpg"
curl -fsSL -O "${RELEASES}/${TAG}/SHA256SUMS"
curl -fsSL -O "${RELEASES}/${TAG}/SHA256SUMS.asc"
DEB="${PRODUCT}_${VERSION}_${ARCH}.deb"
curl -fsSL -o "${DEB}" "${RELEASES}/${TAG}/${DEB}"

echo "== verify SHA256SUMS is release-signed"
mkdir -p gnupg
chmod 700 gnupg
gpg --homedir gnupg --batch --import public.gpg
gpg --homedir gnupg --batch --verify SHA256SUMS.asc SHA256SUMS

echo "== verify the package against SHA256SUMS"
grep -F " ${DEB}" SHA256SUMS | sha256sum -c -

echo "== install (apt resolves dependencies)"
if [ "$(id -u)" -eq 0 ]; then
    apt-get install -y "./${DEB}"
else
    sudo apt-get install -y "./${DEB}"
fi

"${PRODUCT}" --version
echo "installed: ${PRODUCT} ${VERSION}"
