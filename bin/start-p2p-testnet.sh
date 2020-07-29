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

PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/../"
cd ${PROJECT_PATH}

DO_PULL=${DO_PULL:-1}

if [[ ${DO_PULL} -gt 0 ]]
then
  docker pull divax/iroha:latest
  docker pull divax/iroha-node:latest
fi

# used to store temporary data related to running containers
DATA_PATH=${PROJECT_PATH}data/
if [[ ! -f ${DATA_PATH}instance ]]
then
  echo 1 >${DATA_PATH}instance
fi

IDENT_INSTANCE=$(<${DATA_PATH}instance)
#@TODO hard coded upper limit of running instances
if [[ ${IDENT_INSTANCE} -gt 100 ]]
then
  echo "ERROR: too many instances"
  exit 2
fi

PATH_INPUT_YML=p2p-docker-compose.yml
BLOCKCHAIN_NETWORK=${BLOCKCHAIN_NETWORK}
JOIN=${JOIN}

if (test ${JOIN:-"0"} = "0" || test ${BLOCKCHAIN_NETWORK:-"0"} = "0")
then
  BLOCKCHAIN_NETWORK=${BLOCKCHAIN_NETWORK:-tn-`date -u +%s`-${RANDOM}}
  declare -a member=("testnet-a" "testnet-b" "testnet-c")
else
  declare -a member=("${BLOCKCHAIN_NETWORK}-`date -u +%s`-${RANDOM}")
fi

for NAME_KEY in "${member[@]}"
do
  NETWORK_NAME=diva-p2p-net-${IDENT_INSTANCE}

  # create network
  [[ $(docker network inspect ${NETWORK_NAME} 2>/dev/null | wc -l) > 1 ]] || \
    docker network create \
      --driver=bridge \
      --subnet=172.18.${IDENT_INSTANCE}.0/24 \
      --gateway=172.18.${IDENT_INSTANCE}.1 \
      ${NETWORK_NAME}

  PATH_OUTPUT_YML=${DATA_PATH}p2p-dc${IDENT_INSTANCE}.yml
  source ${PWD}/iroha-diva.env
  envsubst <${PATH_INPUT_YML} >${PATH_OUTPUT_YML}

  echo "Starting instance ${IDENT_INSTANCE}; Key: ${NAME_KEY}; Config: ${PATH_OUTPUT_YML}"
  docker-compose -f ${PATH_OUTPUT_YML} up -d
  rm ${PATH_OUTPUT_YML}

  IDENT_INSTANCE=$((IDENT_INSTANCE + 1))
  echo ${IDENT_INSTANCE} >${DATA_PATH}instance
done
