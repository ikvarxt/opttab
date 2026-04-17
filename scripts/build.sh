#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$ROOT_DIR/build/OptTab.app"

cd "$ROOT_DIR"

usage() {
  cat <<'USAGE'
Usage: scripts/build.sh [command]

Commands:
  all      Build debug, package release app, and verify signature. Default.
  debug    Run swift build.
  package  Build and sign build/OptTab.app.
  verify   Verify build/OptTab.app signature and Info.plist.
  open     Open build/OptTab.app.
USAGE
}

debug_build() {
  swift build
}

package_app() {
  bash "$ROOT_DIR/scripts/package_app.sh"
}

verify_app() {
  if [[ ! -d "$APP_DIR" ]]; then
    echo "Missing $APP_DIR. Run scripts/build.sh package first." >&2
    exit 1
  fi

  plutil -lint "$APP_DIR/Contents/Info.plist"
  codesign --verify --verbose=4 "$APP_DIR"
}

open_app() {
  if [[ ! -d "$APP_DIR" ]]; then
    echo "Missing $APP_DIR. Run scripts/build.sh package first." >&2
    exit 1
  fi

  open "$APP_DIR"
}

command="${1:-all}"

case "$command" in
  all)
    debug_build
    package_app
    verify_app
    ;;
  debug)
    debug_build
    ;;
  package)
    package_app
    ;;
  verify)
    verify_app
    ;;
  open)
    open_app
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    echo "Unknown command: $command" >&2
    usage >&2
    exit 1
    ;;
esac
