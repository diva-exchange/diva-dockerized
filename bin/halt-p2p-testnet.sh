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

IDENT_INSTANCE=0
NAME_NETWORK=diva-p2p-net

declare -a testnet=("testnet-a" "testnet-b" "testnet-c")
for NAME_KEY in "${testnet[@]}"; do
  IDENT_INSTANCE=$((IDENT_INSTANCE + 1))

  [[ $(docker inspect p2p-iroha${IDENT_INSTANCE} 2>/dev/null | wc -l) > 1 ]] && \
    docker stop p2p-iroha${IDENT_INSTANCE} && \
    docker rm p2p-iroha${IDENT_INSTANCE}

  [[ $(docker inspect p2p-iroha-node${IDENT_INSTANCE} 2>/dev/null | wc -l) > 1 ]] && \
    docker stop p2p-iroha-node${IDENT_INSTANCE} && \
    docker rm p2p-iroha-node${IDENT_INSTANCE}

  # drop network
  [[ $(docker network inspect ${NAME_NETWORK}${IDENT_INSTANCE} 2>/dev/null | wc -l) > 1 ]] && \
    docker network rm ${NAME_NETWORK}${IDENT_INSTANCE}

  # remove volumes
  docker volume rm p2p-iroha${IDENT_INSTANCE} -f
  docker volume rm p2p-iroha-node${IDENT_INSTANCE} -f
done

# drop tmp_default network
[[ $(docker network inspect tmp_default 2>/dev/null | wc -l) > 1 ]] && \
  docker network rm tmp_default
