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

PATH_INPUT_YML=template.docker-compose.yml
IDENT_INSTANCE=0

declare -a testnet=("testnet-a" "testnet-b" "testnet-c")
for NAME_KEY in "${testnet[@]}"; do
  IDENT_INSTANCE=$((IDENT_INSTANCE + 1))

  PATH_OUTPUT_YML=/tmp/docker-compose-${IDENT_INSTANCE}.yml
  source ${PWD}/iroha-diva.env
  envsubst <${PATH_INPUT_YML} >${PATH_OUTPUT_YML}

  echo "Stopping instance ${IDENT_INSTANCE} with key ${NAME_KEY}"
  docker-compose -f ${PATH_OUTPUT_YML} down
  rm ${PATH_OUTPUT_YML}

  # drop network
  [[ $(docker network inspect diva-net-${IDENT_INSTANCE} 2>/dev/null | wc -l) > 1 ]] && \
    docker network rm diva-net-${IDENT_INSTANCE}
done
