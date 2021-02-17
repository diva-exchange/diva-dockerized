#!/usr/bin/env bash
#
# Copyright (C) 2020 diva.exchange
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# Author/Maintainer: Konrad Bächler <konrad@diva.exchange>
#

PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"/../
cd ${PROJECT_PATH}
PROJECT_PATH=`pwd`/

NODE=${NODE:-0}
if [[ ! -f ${PROJECT_PATH}data/${NODE}.testnet.diva.i2p ]]
then
  echo "Node ${NODE}.testnet.diva.i2p not running"
  exit 1
fi

IDENT=${NODE}
DOMAIN=${DOMAIN:-testnet.diva.i2p}
NAME_IROHA=${IDENT}.${DOMAIN}
NAME_DB=${IDENT}.db.${DOMAIN}
NAME_API=${IDENT}.api.${DOMAIN}

# stopping Iroha
echo "Stopping Iroha ${NAME_IROHA}..."
docker stop ${NAME_IROHA}

# removing prepared transactions from DB
echo "Removing prepared transactions from ${NAME_DB}..."
docker exec ${NAME_DB} psql -U iroha -d iroha -t -c "ROLLBACK PREPARED 'prepared_block_iroha'"

# restarting database
echo "Restarting database ${NAME_DB}..."
docker restart ${NAME_DB}

# starting Iroha
echo "Starting Iroha ${NAME_IROHA}..."
# touch ${PROJECT_PATH}data/reuse_state
# docker cp ${PROJECT_PATH}data/reuse_state ${NAME_IROHA}:/opt/iroha/import/reuse_state
# rm -f ${PROJECT_PATH}data/reuse_state
docker start ${NAME_IROHA}
