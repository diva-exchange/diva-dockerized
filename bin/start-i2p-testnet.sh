#!/usr/bin/env bash
#
# Author/Maintainer: konrad@diva.exchange
#

# -e Exit immediately if a simple command exits with a non-zero status
set -e
# -a Export variables
set -a

PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd ${PROJECT_PATH}/../

PATH_INPUT_YML=i2p-docker-compose.yml
IDENT_INSTANCE=0
NAME_NETWORK=diva-i2p-net

declare -a testnet=("testnet-a" "testnet-b" "testnet-c")
for NAME_KEY in "${testnet[@]}"; do
  IDENT_INSTANCE=$((IDENT_INSTANCE + 1))

  # create network
  [[ $(docker network inspect ${NAME_NETWORK}${IDENT_INSTANCE} 2>/dev/null | wc -l) > 1 ]] || \
    docker network create \
      --driver=bridge \
      --subnet=172.18.${IDENT_INSTANCE}.0/24 \
      --gateway=172.18.${IDENT_INSTANCE}.1 \
      ${NAME_NETWORK}${IDENT_INSTANCE}

  PATH_OUTPUT_YML=/tmp/i2p-dc${IDENT_INSTANCE}.yml
  source ${PWD}/iroha-diva.env
  envsubst <${PATH_INPUT_YML} >${PATH_OUTPUT_YML}

  echo "Starting instance ${IDENT_INSTANCE} with key ${NAME_KEY}, ${PATH_OUTPUT_YML}"
  docker-compose -f ${PATH_OUTPUT_YML} up -d
  rm ${PATH_OUTPUT_YML}
done
