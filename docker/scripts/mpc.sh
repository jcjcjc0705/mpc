#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/../compose/docker-compose-mpc.yml"
ENV_FILE="$SCRIPT_DIR/../compose/.env"
XML_TEMPLATE="$SCRIPT_DIR/../compose/fastdds_wsl.xml"
XML_RUNTIME="/tmp/fastdds_wsl_runtime.xml"

# Dynamically resolve Windows host IP from WSL2
WINDOWS_IP=$(grep nameserver /etc/resolv.conf | awk '{print $2}')
echo "Windows host IP: $WINDOWS_IP"

# Inject IP into FastDDS config
sed "s/WINDOWS_HOST_IP/$WINDOWS_IP/g" "$XML_TEMPLATE" > "$XML_RUNTIME"

docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" pull

docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" \
    run --rm -d \
    -v "$XML_RUNTIME":/workspaces/fastdds_wsl.xml \
    --name mpc_isaac \
    mpc_isaac bash -l

docker exec -it mpc_isaac bash
