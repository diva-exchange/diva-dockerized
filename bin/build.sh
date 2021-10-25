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

# load helpers
source "${PROJECT_PATH}bin/util/echos.sh"
source "${PROJECT_PATH}bin/util/helpers.sh"

# env vars
PURGE=${PURGE:-0}
JOIN_NETWORK=${JOIN_NETWORK:-}
SIZE_NETWORK=${SIZE_NETWORK:-7}
BASE_DOMAIN=${BASE_DOMAIN:-testnet.diva.i2p}
BASE_IP=${BASE_IP:-172.19.72.}
PORT=${PORT:-17468}
HAS_I2P=${HAS_I2P:-0}
I2P_CONSOLE_PORT=${I2P_CONSOLE_PORT:-7070}
NODE_ENV=${NODE_ENV:-production}
LOG_LEVEL=${LOG_LEVEL:-trace}
NETWORK_VERBOSE_LOGGING=${NETWORK_VERBOSE_LOGGING:-0}

if ! command_exists npm; then
  error "npm not available. Please install it first.";
  exit 1
fi

if ! command_exists docker; then
  error "docker not available. Please install it first.";
  exit 2
fi

if ! command_exists docker-compose; then
  error "docker-compose not available. Please install it first.";
  exit 3
fi

if [[ -f ${PROJECT_PATH}build/${BASE_DOMAIN}.yml ]]
then
  sudo docker-compose -f ${PROJECT_PATH}build/${BASE_DOMAIN}.yml down
fi

if [[ ${PURGE} > 0 ]]
then
  warn "The confirmation of this action will lead to DATA LOSS!"
  warn "If you want to keep the data, run a backup first."
  confirm "Do you want to DELETE all local data and re-create your environment (y/N)?" || exit 4
  if [[ -f ${PROJECT_PATH}build/${BASE_DOMAIN}.yml ]]
  then
    sudo docker-compose -f ${PROJECT_PATH}build/${BASE_DOMAIN}.yml down --volumes
    BASE_DOMAIN=${BASE_DOMAIN} \
      ${PROJECT_PATH}build/bin/clean.sh
  fi
fi

info "Rebuilding..."

rm -rf ${PROJECT_PATH}node_modules
rm -rf ${PROJECT_PATH}package-lock.json

npm i

if [[ ${HAS_I2P} > 0 ]]
then
  SIZE_NETWORK=${SIZE_NETWORK} \
    BASE_DOMAIN=${BASE_DOMAIN} \
    BASE_IP=${BASE_IP} \
    PORT=${PORT} \
    CREATE_I2P=1 \
    ${PROJECT_PATH}node_modules/.bin/ts-node ${PROJECT_PATH}build/main.ts

  sudo docker-compose -f ${PROJECT_PATH}build/i2p.${BASE_DOMAIN}.yml up -d
  sleep 10
  curl -s http://${BASE_IP}10:${I2P_CONSOLE_PORT}/?page=i2p_tunnels >${PROJECT_PATH}build/b32/${BASE_DOMAIN}
  sudo docker-compose -f ${PROJECT_PATH}build/i2p.${BASE_DOMAIN}.yml down
fi

JOIN_NETWORK=${JOIN_NETWORK} \
  SIZE_NETWORK=${SIZE_NETWORK} \
  BASE_DOMAIN=${BASE_DOMAIN} \
  BASE_IP=${BASE_IP} \
  PORT=${PORT} \
  HAS_I2P=${HAS_I2P} \
  NODE_ENV=${NODE_ENV} \
  LOG_LEVEL=${LOG_LEVEL} \
  NETWORK_VERBOSE_LOGGING=${NETWORK_VERBOSE_LOGGING} \
  ${PROJECT_PATH}node_modules/.bin/ts-node ${PROJECT_PATH}build/main.ts
