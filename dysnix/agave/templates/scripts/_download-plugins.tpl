#!/usr/bin/env sh
# shellcheck disable=SC3040,SC2046

set -e

YELLOWSTONE_GRPC__PLUGIN_DIR="$PLUGINS_DIR/yellowstone-grpc"
RICHAT__PLUGIN_DIR="$PLUGINS_DIR/richat"

yellowstone_grpc_bootstrap() {
    echo "Yellowstone gRPC: Downloading plugin version ${YELLOWSTONE_GRPC__VERSION}.."
    mkdir -p "$YELLOWSTONE_GRPC__PLUGIN_DIR"
    wget -qO- "${YELLOWSTONE_GRPC__DOWNLOAD_URL}/${YELLOWSTONE_GRPC__VERSION}/yellowstone-grpc-geyser-release22-x86_64-unknown-linux-gnu.tar.bz2" | tar jxvf -

    echo "Yellowstone gRPC: Copying lib to ${YELLOWSTONE_GRPC__PLUGIN_DIR}.."
    cp -r /tmp/yellowstone-grpc-geyser-release/lib "$YELLOWSTONE_GRPC__PLUGIN_DIR/"

    echo "Yellowstone gRPC: Copying config file to ${YELLOWSTONE_GRPC__PLUGIN_DIR}.."
    cp -L "$YELLOWSTONE_GRPC__CONFIG_PATH" "$YELLOWSTONE_GRPC__PLUGIN_DIR/config.json"

    echo "Yellowstone gRPC: Changing listen IP address in config file to ${YELLOWSTONE_GRPC__LISTEN_IP}.."
    sed -i "s/LISTEN_IP/${YELLOWSTONE_GRPC__LISTEN_IP}/g" "$YELLOWSTONE_GRPC__PLUGIN_DIR/config.json"

    echo "Yellowstone gRPC: Bootstrap done!"
}

richat_bootstrap() {
    echo "Richat: Downloading plugin version ${RICHAT__VERSION}.."
    mkdir -p "$RICHAT__PLUGIN_DIR/lib"
    wget -q "${RICHAT__DOWNLOAD_URL}" -O "$RICHAT__PLUGIN_DIR/lib/librichat_plugin_agave.so"

    echo "Richat: Copying config file to ${RICHAT__PLUGIN_DIR}.."
    cp -L "$RICHAT__CONFIG_PATH" "$RICHAT__PLUGIN_DIR/config.json"

    echo "Richat: Changing listen IP address in config file to ${RICHAT__LISTEN_IP}.."
    sed -i "s/LISTEN_IP/${RICHAT__LISTEN_IP}/g" "$RICHAT__PLUGIN_DIR/config.json"

    echo "Richat: Bootstrap done!"
}

main() {
    cd /tmp
    if [ "$YELLOWSTONE_GRPC__ENABLED" = "1" ]; then yellowstone_grpc_bootstrap; fi
    if [ "$RICHAT__ENABLED" = "1" ]; then richat_bootstrap; fi
}

main
