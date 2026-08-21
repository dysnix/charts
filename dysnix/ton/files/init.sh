
#!/bin/sh
#
# TON_ROOT="/var/ton-work/db"
# CONSOLE_PORT="30001"

ETC_ROOT="$TON_ROOT/etc"
LOG_ROOT="$TON_ROOT/log"
CERT_ROOT="$ETC_ROOT/node_certs"
MAINNET_CONFIG_URL="https://ton.org/global-config.json"
MAINNET_CONFIG="$ETC_ROOT/global-config.json"
NODE_CONFIG="$TON_ROOT/config.json"
KEYRING_ROOT="$TON_ROOT/keyring"
# Function for execute generate-random-id in specific directory
generate_random_id() {
    local mode=$1
    local key_name=$2
    local mv
    if [ ! -f "${CERT_ROOT}/${key_name}" ]; then
        cd $CERT_ROOT
        read -r PRI PUB <<< $(generate-random-id -m $mode -n $key_name)
        echo "{\"PRI\": \"${PRI}\",\"PUB\": \"${PUB}\"}" > "${CERT_ROOT}/json_${key_name}"
        if [ $key_name == "server" ]; then
            cp "${CERT_ROOT}/${key_name}" "${KEYRING_ROOT}/${PRI}"
        fi
        if [ $key_name == "liteserver" ]; then
            cp "${CERT_ROOT}/${key_name}" "${KEYRING_ROOT}/${PRI}"
        fi
    else
        echo -e "##### Found existing ${key_name} keys, skipping"
    fi
}

mkdir -p $ETC_ROOT
mkdir -p $KEYRING_ROOT
mkdir -p $CERT_ROOT

# GET IP
PUBLIC_IP=$(curl -s ifconfig.me)

# DOWNLOAD MAINNET CONFIG

if [ -f $MAINNET_CONFIG ]; then
    echo -e "##### Found existing global config, skipping"
else
    echo -e "##### Downloading provided global config."
    wget -q $MAINNET_CONFIG_URL -O $MAINNET_CONFIG
fi

# GENERATE CONFIG
if [ -f $NODE_CONFIG ]; then
    echo -e "##### Found existing local config, skipping"
else
    echo -e "##### Using provided IP: $PUBLIC_IP:$CONSOLE_PORT"
    validator-engine -C $MAINNET_CONFIG --db $TON_ROOT --ip "$PUBLIC_IP:$CONSOLE_PORT"
fi



# GENERATE CERTIFICATES
generate_random_id "keys" "server"
generate_random_id "keys" "client"
generate_random_id "keys" "liteserver"