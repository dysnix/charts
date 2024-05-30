#!/usr/bin/env sh
# shellcheck disable=SC3040,SC2046

set -e

YELLOWSTONE_GRPC__PLUGIN_DIR="$PLUGINS_DIR/yellowstone-grpc"

yellowstone_grpc_bootstrap() {
    echo "Downloading Yellowstone gRPC plugin version ${YELLOWSTONE_GRPC__VERSION}.."
    mkdir -p "$YELLOWSTONE_GRPC__PLUGIN_DIR"
    wget -q "${YELLOWSTONE_GRPC__BASE_URL}/${YELLOWSTONE_GRPC__VERSION}/geyser.proto"
    wget -q "${YELLOWSTONE_GRPC__BASE_URL}/${YELLOWSTONE_GRPC__VERSION}/solana-storage.proto"
    wget -qO- "${YELLOWSTONE_GRPC__BASE_URL}/${YELLOWSTONE_GRPC__VERSION}/yellowstone-grpc-geyser-release-x86_64-unknown-linux-gnu.tar.bz2" | tar jxvf -

    echo "Copying Yellowstone protofiles and lib to ${YELLOWSTONE_GRPC__PLUGIN_DIR}.."
    cp -r /tmp/*.proto "$YELLOWSTONE_GRPC__PLUGIN_DIR/"
    cp -r /tmp/yellowstone-grpc-geyser-release/lib "$YELLOWSTONE_GRPC__PLUGIN_DIR/"

    echo "Copying Yellowstone config to ${YELLOWSTONE_GRPC__PLUGIN_DIR}.."
    cp -L "$YELLOWSTONE_GRPC__CONFIG_PATH" "$YELLOWSTONE_GRPC__PLUGIN_DIR/config.json"

    echo "Changing Yellowstone gRPC listen IP address to ${YELLOWSTONE_GRPC__LISTEN_IP}"
    sed -i "s/LISTEN_IP/${YELLOWSTONE_GRPC__LISTEN_IP}/g" "$YELLOWSTONE_GRPC__PLUGIN_DIR/config.json"

    echo "Yellowstone gRPC bootstrap done!"
}

main() {
  cd /tmp

  if [ "$YELLOWSTONE_GRPC__ENABLED" = "1" ]; then
      yellowstone_grpc_bootstrap
  else
      echo "Yellowstone gRPC is not enabled, skipping download."
      exit 0
  fi
}

main