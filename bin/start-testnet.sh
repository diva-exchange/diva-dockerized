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
# -e  Exit immediately if a simple command exits with a non-zero status
set -e

PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"/../
cd ${PROJECT_PATH}
PROJECT_PATH=`pwd`/

NODES=${NODES:-7}

DOMAIN=${DOMAIN:-testnet.diva.i2p}
NAME_NETWORK=${NAME_NETWORK:-network.${DOMAIN}}

NAME_EXPLORER=${NAME_EXPLORER:-explorer.${DOMAIN}}
IP_EXPLORER=172.20.101.3

NAME_I2P=${NAME_I2P:-i2p.${DOMAIN}}
IP_I2P=172.20.101.4

NAME_API=${NAME_API:-api.${DOMAIN}}
IP_API=172.20.101.5

# network
echo "Creating network ${NAME_NETWORK}..."
if [[ ! `docker network ls | fgrep ${NAME_NETWORK}` ]]
then
  docker network create \
    --driver bridge \
    --ipam-driver default \
    --subnet 172.20.101.0/24 \
    ${NAME_NETWORK} \
    >/dev/null
fi

# i2p
echo "Starting i2p ${NAME_I2P} on ${IP_I2P}..."
docker run \
  --detach \
  --name ${NAME_I2P} \
  --restart unless-stopped \
  --network ${NAME_NETWORK} \
  --ip ${IP_I2P} \
  --env ENABLE_TUNNELS=1 \
  --volume ${NAME_I2P}:/home/i2pd/data/ \
  --volume ${PROJECT_PATH}tunnels.conf.d/testnet:/home/i2pd/tunnels.source.conf.d/ \
  divax/i2p:latest \
  >/dev/null

# postgres and iroha
IP_IROHA_START=120
ADD_HOSTS=""
NO_PROXY=""
for (( t=1; t<=${NODES}; t++ ))
do
  IP_IROHA=172.20.101.$(( ${IP_IROHA_START} + ${t} ))
  ADD_HOSTS="${ADD_HOSTS}--add-host n${t}.${DOMAIN}:${IP_IROHA}"
  [[ ${t} -lt ${NODES} ]] && ADD_HOSTS="${ADD_HOSTS} "
  NO_PROXY="${NO_PROXY}n${t}.${DOMAIN}"
  [[ ${t} -lt ${NODES} ]] && NO_PROXY="${NO_PROXY},"
done
echo "ADD_HOSTS: ${ADD_HOSTS}"
echo "NO_PROXY: ${NO_PROXY}"

IP_POSTGRES_START=20
for (( t=1; t<=${NODES}; t++ ))
do
  IP_POSTGRES=172.20.101.$(( ${IP_POSTGRES_START} + ${t} ))
  echo "Starting database n${t}.db.${DOMAIN} on ${IP_POSTGRES}..."
  docker run \
    --detach \
    --name n${t}.db.${DOMAIN} \
    --restart unless-stopped \
    --stop-timeout 5 \
    --network ${NAME_NETWORK} \
    --ip ${IP_POSTGRES} \
    --env POSTGRES_DATABASE=iroha \
    --env POSTGRES_USER=iroha \
    --env POSTGRES_PASSWORD=iroha \
    --volume n${t}.db.${DOMAIN}:/var/lib/postgresql/data/ \
    postgres:10-alpine \
    --max_prepared_transactions=100 \
    >/dev/null

  IP_IROHA=172.20.101.$(( ${IP_IROHA_START} + ${t} ))
  echo "Starting Iroha n${t}.${DOMAIN} on ${IP_IROHA}..."
  docker run \
    ${ADD_HOSTS} \
    --detach \
    --name n${t}.${DOMAIN} \
    --restart unless-stopped \
    --stop-timeout 5 \
    --network ${NAME_NETWORK} \
    --ip ${IP_IROHA} \
    --env IP_POSTGRES=${IP_POSTGRES} \
    --env NAME_DATABASE=iroha \
    --env NAME_PEER=n${t} \
    --env BLOCKCHAIN_NETWORK=testnet.diva.i2p \
    --env IP_HTTP_PROXY=${IP_I2P} \
    --env PORT_HTTP_PROXY=4444 \
    --env NO_PROXY=${NO_PROXY} \
    --volume n${t}.${DOMAIN}:/opt/iroha/ \
    divax/iroha:1.2.0-prop-strategy \
    >/dev/null
done

echo "Starting API ${NAME_API} on ${IP_API}..."
docker run \
  --detach \
  --name ${NAME_API} \
  --restart unless-stopped \
  --network ${NAME_NETWORK} \
  --ip ${IP_API} \
  --env NODE_ENV=development \
  --env TORII=172.20.101.121:50051 \
  --env CREATOR_ACCOUNT=diva@testnet.diva.i2p \
  --env I2P_HOSTNAME=${IP_I2P} \
  --env I2P_HTTP_PROXY_PORT=4444 \
  --env I2P_WEBCONSOLE_PORT=7070 \
  --volume ${NAME_API}:/home/node/data/ \
  --volume n1.${DOMAIN}:/tmp/iroha/ \
  divax/iroha-node:api-ws \
  >/dev/null

# explorer
echo "Starting Explorer ${NAME_EXPLORER} on ${IP_EXPLORER}..."
docker run \
  --detach \
  --name ${NAME_EXPLORER} \
  --restart unless-stopped \
  --network ${NAME_NETWORK} \
  --ip ${IP_EXPLORER} \
  --env IP_EXPLORER=0.0.0.0 \
  --env PORT_EXPLORER=3920 \
  --env PATH_IROHA=/tmp/iroha/ \
  --publish 3920:3920 \
  --volume n1.${DOMAIN}:/tmp/iroha/:ro \
  divax/iroha-explorer:latest \
  >/dev/null
