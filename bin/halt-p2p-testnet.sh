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

# used to store temporary data related to running containers
DATA_PATH=${PROJECT_PATH}data/

if [[ ! -f ${DATA_PATH}instance ]]
then
  exit 1
fi

for (( IDENT_INSTANCE=1; IDENT_INSTANCE < $(<${DATA_PATH}instance); IDENT_INSTANCE++ ))
do
  NETWORK_NAME=diva-p2p-net-${IDENT_INSTANCE}

  [[ $(docker inspect p2p-iroha${IDENT_INSTANCE} 2>/dev/null | wc -l) > 1 ]] && \
    docker stop p2p-iroha${IDENT_INSTANCE} && \
    docker rm p2p-iroha${IDENT_INSTANCE}

  [[ $(docker inspect p2p-iroha-node${IDENT_INSTANCE} 2>/dev/null | wc -l) > 1 ]] && \
    docker stop p2p-iroha-node${IDENT_INSTANCE} && \
    docker rm p2p-iroha-node${IDENT_INSTANCE}

  # drop network
  [[ $(docker network inspect ${NETWORK_NAME} 2>/dev/null | wc -l) > 1 ]] && \
    docker network rm ${NETWORK_NAME}

  # remove volumes
  docker volume rm p2p-iroha${IDENT_INSTANCE} -f
  docker volume rm p2p-iroha-node${IDENT_INSTANCE} -f
done

# drop tmp_default network
[[ $(docker network inspect tmp_default 2>/dev/null | wc -l) > 1 ]] && \
  docker network rm tmp_default

rm -f ${DATA_PATH}instance
rm -f ${DATA_PATH}has-testnet
