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
