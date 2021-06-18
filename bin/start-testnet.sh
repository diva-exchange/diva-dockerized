#!/usr/bin/env bash
#
# Copyright (C) 2021 diva.exchange
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
I2P_VERSION_TAG=${I2P_VERSION_TAG:-latest}
CHAIN_VERSION_TAG=${CHAIN_VERSION_TAG:-latest}
EXPLORER_VERSION_TAG=${EXPLORER_VERSION_TAG:-latest}

DOMAIN=${DOMAIN:-testnet.diva.i2p}
NAME_NETWORK=${NAME_NETWORK:-network.${DOMAIN}}

# pulling images
docker pull divax/i2p:${I2P_VERSION_TAG}
docker pull divax/divachain:${CHAIN_VERSION_TAG}
docker pull divax/explorer:${EXPLORER_VERSION_TAG}

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
NAME_I2P=${NAME_I2P:-i2p.${DOMAIN}}
IP_I2P=172.20.101.102
echo "Starting I2P ${NAME_I2P} on ${IP_I2P}..."
docker run \
  --detach \
  --name ${NAME_I2P} \
  --restart unless-stopped \
  --network ${NAME_NETWORK} \
  --ip ${IP_I2P} \
  --env ENABLE_TUNNELS=1 \
  --volume ${NAME_I2P}:/home/i2pd/data/ \
  --volume ${PROJECT_PATH}tunnels.conf.d/testnet:/home/i2pd/tunnels.source.conf.d/ \
  divax/i2p:${I2P_VERSION_TAG} \
  >/dev/null

# divachain
for (( t=1; t<=${NODES}; t++ ))
do
  IP_CHAIN=172.20.101.$(( 102 + ${t} ))
  echo "Starting DIVACHAIN n${t}.${DOMAIN} on ${IP_CHAIN}..."
  docker run \
    --detach \
    --name n${t}.${DOMAIN} \
    --restart unless-stopped \
    --stop-timeout 5 \
    --network ${NAME_NETWORK} \
    --ip ${IP_CHAIN} \
    --env NODE_ENV=production \
    --env LOG_LEVEL=trace \
    --env IP=${IP_CHAIN} \
    --env PORT=17468 \
    --env I2P_SOCKS_PROXY_HOST=${IP_I2P} \
    --env I2P_SOCKS_PROXY_PORT=4445 \
    --env I2P_SOCKS_PROXY_CONSOLE_PORT=7070 \
    --env NETWORK_VERBOSE_LOGGING=0 \
    --volume n${t}.${DOMAIN}:/ \
    --volume ${PROJECT_PATH}keys/n${t}.${DOMAIN}:/keys/ \
    --volume ${PROJECT_PATH}genesis:/genesis/ \
    divax/divachain:${CHAIN_VERSION_TAG} \
    >/dev/null
done

# explorer
NAME_EXPLORER=${NAME_EXPLORER:-explorer.${DOMAIN}}
IP_EXPLORER=172.20.101.101
echo "Starting Explorer ${NAME_EXPLORER} on ${IP_EXPLORER}..."
docker run \
  --detach \
  --name ${NAME_EXPLORER} \
  --restart unless-stopped \
  --network ${NAME_NETWORK} \
  --ip ${IP_EXPLORER} \
  --env HTTP_IP=${IP_EXPLORER} \
  --env HTTP_PORT=3920 \
  --env URL_API=http://172.20.101.103:17468 \
  divax/explorer:${EXPLORER_VERSION_TAG} \
  >/dev/null
