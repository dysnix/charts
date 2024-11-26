#!/usr/bin/env sh
# shellcheck disable=SC3040,SC2046

set -e

YELLOWSTONE_GRPC__PLUGIN_DIR="$PLUGINS_DIR/yellowstone-grpc"
JITO_GRPC__PLUGIN_DIR="$PLUGINS_DIR/jito-grpc"

yellowstone_grpc_bootstrap() {
    echo "Yellowstone gRPC: Downloading plugin version ${YELLOWSTONE_GRPC__VERSION}.."
    mkdir -p "$YELLOWSTONE_GRPC__PLUGIN_DIR"
    wget -q "${YELLOWSTONE_GRPC__DOWNLOAD_URL}/${YELLOWSTONE_GRPC__VERSION}/geyser.proto"
    wget -q "${YELLOWSTONE_GRPC__DOWNLOAD_URL}/${YELLOWSTONE_GRPC__VERSION}/solana-storage.proto"
    wget -qO- "${YELLOWSTONE_GRPC__DOWNLOAD_URL}/${YELLOWSTONE_GRPC__VERSION}/yellowstone-grpc-geyser-release-x86_64-unknown-linux-gnu.tar.bz2" | tar jxvf -

    echo "Yellowstone gRPC: Copying proto and lib to ${YELLOWSTONE_GRPC__PLUGIN_DIR}.."
    cp -r /tmp/*.proto "$YELLOWSTONE_GRPC__PLUGIN_DIR/"
    cp -r /tmp/yellowstone-grpc-geyser-release/lib "$YELLOWSTONE_GRPC__PLUGIN_DIR/"

    echo "Yellowstone gRPC: Copying config file to ${YELLOWSTONE_GRPC__PLUGIN_DIR}.."
    cp -L "$YELLOWSTONE_GRPC__CONFIG_PATH" "$YELLOWSTONE_GRPC__PLUGIN_DIR/config.json"

    echo "Yellowstone gRPC: Changing listen IP address in config file to ${YELLOWSTONE_GRPC__LISTEN_IP}.."
    sed -i "s/LISTEN_IP/${YELLOWSTONE_GRPC__LISTEN_IP}/g" "$YELLOWSTONE_GRPC__PLUGIN_DIR/config.json"

    echo "Yellowstone gRPC: Bootstrap done!"
}

jito_grpc_bootstrap() {
    mkdir -p "$JITO_GRPC__PLUGIN_DIR"

    echo "Jito gRPC: Copying config file to ${JITO_GRPC__PLUGIN_DIR}.."
    cp -L "$JITO_GRPC__CONFIG_PATH" "$JITO_GRPC__PLUGIN_DIR/config.json"

    echo "Jito gRPC: Changing listen IP address in config file to ${JITO_GRPC__LISTEN_IP}.."
    sed -i "s/LISTEN_IP/${JITO_GRPC__LISTEN_IP}/g" "$JITO_GRPC__PLUGIN_DIR/config.json"

    echo "Jito gRPC: Bootstrap done!"
}

main() {
    cd /tmp
    if [ "$YELLOWSTONE_GRPC__ENABLED" = "1" ]; then yellowstone_grpc_bootstrap; fi
    if [ "$JITO_GRPC__ENABLED" = "1" ]; then jito_grpc_bootstrap; fi
}

main