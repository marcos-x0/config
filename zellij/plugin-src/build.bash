#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CARGO_TOML="$SCRIPT_DIR/Cargo.toml"
WASM_OUT="$SCRIPT_DIR/target/wasm32-wasip1/release/zj-status-bar.wasm"
INSTALL_PATH="$SCRIPT_DIR/../zj-status-bar.wasm"

# detect zellij version
if ! command -v zellij &>/dev/null; then
    echo "error: zellij not found in PATH"
    exit 1
fi
ZELLIJ_VERSION="$(zellij --version | awk '{print $2}')"
echo "detected zellij $ZELLIJ_VERSION"

# detect current dep version in Cargo.toml
CURRENT_VERSION="$(grep '^zellij-tile ' "$CARGO_TOML" | sed 's/.*"\(.*\)"/\1/')"
echo "current zellij-tile dep: $CURRENT_VERSION"

# update deps if needed
if [ "$CURRENT_VERSION" != "$ZELLIJ_VERSION" ]; then
    echo "updating zellij-tile deps $CURRENT_VERSION -> $ZELLIJ_VERSION"
    sed -i '' "s/zellij-tile = \"$CURRENT_VERSION\"/zellij-tile = \"$ZELLIJ_VERSION\"/" "$CARGO_TOML"
    sed -i '' "s/zellij-tile-utils = \"$CURRENT_VERSION\"/zellij-tile-utils = \"$ZELLIJ_VERSION\"/" "$CARGO_TOML"
else
    echo "deps already match"
fi

# ensure rust is installed
. "$HOME/.cargo/env" 2>/dev/null || true
if ! command -v cargo &>/dev/null; then
    echo "rust not found, installing via rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    . "$HOME/.cargo/env"
fi

# ensure wasm target
rustup target add wasm32-wasip1 2>/dev/null || true

# build
echo "building..."
cargo build --release --target wasm32-wasip1 --manifest-path "$CARGO_TOML"

# install
cp "$WASM_OUT" "$INSTALL_PATH"
echo "installed -> $INSTALL_PATH"
