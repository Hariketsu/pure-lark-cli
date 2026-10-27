#!/bin/sh
# Remove the lark-cli binary installed by install.sh.
# The agent skill is managed by `npx skills` and is never touched here.
set -eu

PREFIX="${HOME}/.local/bin"
PURGE=0

usage() {
  cat <<'EOF'
Remove the lark-cli binary installed by install.sh.

Usage: uninstall.sh [options]

Options:
  --prefix <dir>   Directory that holds lark-cli (default: ~/.local/bin)
  --purge          Also sign out and delete ~/.lark-cli (config and login state)
  -h, --help       Show this help
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --prefix) [ $# -ge 2 ] || { printf 'error: --prefix needs a value\n' >&2; exit 1; }; PREFIX="$2"; shift 2 ;;
    --prefix=*) PREFIX="${1#*=}"; shift ;;
    --purge) PURGE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'error: unknown option: %s (try --help)\n' "$1" >&2; exit 1 ;;
  esac
done

case "$PREFIX" in
  "~/"*) PREFIX="${HOME}/${PREFIX#\~/}" ;;
  "~") PREFIX="${HOME}" ;;
esac

bin="${PREFIX}/lark-cli"

if [ -x "$bin" ]; then
  # The CLI has to sign out itself while it still exists: it owns the Keychain entry.
  if [ "$PURGE" -eq 1 ] && "$bin" auth logout >/dev/null 2>&1; then
    printf 'Signed out of lark-cli.\n'
  fi
  rm -f "$bin"
  printf 'Removed %s\n' "$bin"
else
  printf 'Nothing to remove at %s\n' "$bin"
fi

rm -f "${PREFIX}"/.lark-cli.new.* 2>/dev/null || true

if [ "$PURGE" -eq 1 ]; then
  if [ -d "${HOME}/.lark-cli" ]; then
    rm -rf "${HOME}/.lark-cli"
    printf 'Removed %s\n' "${HOME}/.lark-cli"
  else
    printf 'No config directory at %s\n' "${HOME}/.lark-cli"
  fi
else
  if [ -d "${HOME}/.lark-cli" ]; then
    printf 'Kept %s (use --purge to delete config and login state).\n' "${HOME}/.lark-cli"
  fi
fi

if [ -d "${HOME}/.agents/skills/lark" ]; then
  printf 'The agent skill is still installed. Remove it with: npx skills remove -g lark\n'
fi
