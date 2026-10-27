#!/bin/sh
# Install the lark-cli binary from the official GitHub Release.
# Only the binary is installed. Nothing else is touched.
set -eu

REPO="larksuite/cli"
VERSION=""
PREFIX="${HOME}/.local/bin"
DRY_RUN=0
SKIP_NOTARIZATION=0
TMP=""
NEW_BIN=""

usage() {
  cat <<'EOF'
Install the lark-cli binary from the official GitHub Release.

Usage: install.sh [options]

Options:
  --version <version>   Version to install (default: latest release)
  --prefix <dir>        Install directory (default: ~/.local/bin)
  --dry-run             Print the plan without downloading anything
  --skip-notarization   Skip the Apple notarization check (macOS)
  -h, --help            Show this help

The download is verified against the release's checksums.txt (sha256).
On macOS the Apple code signature and notarization are verified as well.
EOF
}

die() { printf 'error: %s\n' "$*" >&2; exit 1; }
info() { printf '%s\n' "$*"; }

cleanup() {
  if [ -n "$NEW_BIN" ]; then rm -f "$NEW_BIN" 2>/dev/null || true; fi
  if [ -n "$TMP" ]; then rm -rf "$TMP" 2>/dev/null || true; fi
}

while [ $# -gt 0 ]; do
  case "$1" in
    --version) [ $# -ge 2 ] || die "--version needs a value"; VERSION="$2"; shift 2 ;;
    --version=*) VERSION="${1#*=}"; shift ;;
    --prefix) [ $# -ge 2 ] || die "--prefix needs a value"; PREFIX="$2"; shift 2 ;;
    --prefix=*) PREFIX="${1#*=}"; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --skip-notarization) SKIP_NOTARIZATION=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown option: $1 (try --help)" ;;
  esac
done

case "$PREFIX" in
  "~/"*) PREFIX="${HOME}/${PREFIX#\~/}" ;;
  "~") PREFIX="${HOME}" ;;
esac

command -v curl >/dev/null 2>&1 || die "curl is required"
command -v tar >/dev/null 2>&1 || die "tar is required"

os=$(uname -s)
case "$os" in
  Darwin) os=darwin ;;
  Linux) os=linux ;;
  *) die "unsupported operating system: ${os} (macOS and Linux only)" ;;
esac

arch=$(uname -m)
case "$arch" in
  x86_64|amd64) arch=amd64 ;;
  arm64|aarch64) arch=arm64 ;;
  riscv64) arch=riscv64 ;;
  *) die "unsupported architecture: ${arch}" ;;
esac

if [ -z "$VERSION" ]; then
  info "Resolving the latest release of ${REPO}..."
  VERSION=$(curl -fsSL --proto '=https' --tlsv1.2 \
      "https://api.github.com/repos/${REPO}/releases/latest" 2>/dev/null \
    | sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"v\{0,1\}\([^"]*\)".*/\1/p' \
    | head -n 1) || VERSION=""
  if [ -z "$VERSION" ] && command -v gh >/dev/null 2>&1; then
    VERSION=$(gh release view --repo "$REPO" --json tagName -q '.tagName' 2>/dev/null | sed 's/^v//') || VERSION=""
  fi
  [ -n "$VERSION" ] || die "could not resolve the latest release; pass --version <version>"
fi
VERSION="${VERSION#v}"

asset="lark-cli-${VERSION}-${os}-${arch}.tar.gz"
base="https://github.com/${REPO}/releases/download/v${VERSION}"
dest="${PREFIX}/lark-cli"

info "  version:  ${VERSION}"
info "  platform: ${os}-${arch}"
info "  asset:    ${asset}"
info "  target:   ${dest}"

if [ "$DRY_RUN" -eq 1 ]; then
  info "dry run: nothing downloaded, nothing changed"
  exit 0
fi

TMP=$(mktemp -d 2>/dev/null || mktemp -d -t lark-cli) || die "cannot create a temp directory"
NEW_BIN="${PREFIX}/.lark-cli.new.$$"
trap cleanup EXIT HUP INT TERM

info "Downloading..."
if [ -t 2 ]; then
  curl -fL --progress-bar --proto '=https' --tlsv1.2 --retry 3 --retry-delay 1 \
    -o "${TMP}/${asset}" "${base}/${asset}" \
    || die "download failed: ${base}/${asset}"
else
  curl -fsSL --proto '=https' --tlsv1.2 --retry 3 --retry-delay 1 \
    -o "${TMP}/${asset}" "${base}/${asset}" \
    || die "download failed: ${base}/${asset}"
fi
curl -fsSL --proto '=https' --tlsv1.2 \
  -o "${TMP}/checksums.txt" "${base}/checksums.txt" \
  || die "could not download checksums.txt"

info "Verifying sha256..."
grep -qF " ${asset}" "${TMP}/checksums.txt" \
  || die "checksums.txt has no entry for ${asset}"
if command -v shasum >/dev/null 2>&1; then
  ( cd "$TMP" && grep -F " ${asset}" checksums.txt | shasum -a 256 -c - ) \
    || die "sha256 mismatch for ${asset}; refusing to install"
elif command -v sha256sum >/dev/null 2>&1; then
  ( cd "$TMP" && grep -F " ${asset}" checksums.txt | sha256sum -c - ) \
    || die "sha256 mismatch for ${asset}; refusing to install"
else
  die "need shasum or sha256sum to verify the download"
fi

info "Extracting the binary..."
tar -xzf "${TMP}/${asset}" -C "$TMP" lark-cli 2>/dev/null \
  || tar -xzf "${TMP}/${asset}" -C "$TMP"
[ -f "${TMP}/lark-cli" ] || die "archive did not contain a lark-cli binary"
chmod 755 "${TMP}/lark-cli"

if [ "$os" = darwin ] && command -v codesign >/dev/null 2>&1; then
  info "Verifying the Apple code signature..."
  codesign --verify --strict "${TMP}/lark-cli" 2>/dev/null \
    || die "code signature verification failed; refusing to install"
  if [ "$SKIP_NOTARIZATION" -eq 0 ]; then
    info "Checking notarization..."
    codesign --verify --strict --check-notarization -R='notarized' "${TMP}/lark-cli" 2>/dev/null \
      || die "notarization check failed; rerun with --skip-notarization if you are offline"
  fi
fi

info "Installing to ${dest}..."
mkdir -p "$PREFIX"
if ! install -m 755 "${TMP}/lark-cli" "$NEW_BIN" 2>/dev/null; then
  cp "${TMP}/lark-cli" "$NEW_BIN" || die "cannot write to ${PREFIX}"
  chmod 755 "$NEW_BIN"
fi
mv -f "$NEW_BIN" "$dest" || die "cannot replace ${dest}"
NEW_BIN=""

info ""
info "Installed ${dest}"
info "  version: $("$dest" --version 2>/dev/null | sed 's/^lark-cli version //' || echo unknown)"
if command -v shasum >/dev/null 2>&1; then
  info "  sha256:  $(shasum -a 256 "$dest" | awk '{print $1}')"
else
  info "  sha256:  $(sha256sum "$dest" | awk '{print $1}')"
fi

case ":${PATH}:" in
  *":${PREFIX}:"*) ;;
  *)
    info ""
    info "warning: ${PREFIX} is not in your PATH; add it to your shell profile."
    ;;
esac
