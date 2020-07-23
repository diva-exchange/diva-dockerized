#!/usr/bin/env bash
#
#    Copyright (C) 2020 diva.exchange
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#
#    Author/Maintainer: Konrad Bächler <konrad@diva.exchange>
#

# -e Exit immediately if a simple command exits with a non-zero status
set -e
# -a Export variables
set -a

PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd ${PROJECT_PATH}/../

docker pull divax/i2p:latest
docker pull divax/iroha:latest
docker pull divax/iroha-node:latest

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
