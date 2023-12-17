#!/usr/bin/env bash
#
# Copyright (C) 2021-2023 diva.exchange
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
# Author/Maintainer: DIVA.EXCHANGE Association <contact@diva.exchange>
#

# -e  Exit immediately if a simple command exits with a non-zero status
set -e

PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"/../
cd "${PROJECT_PATH}"
PROJECT_PATH=$( pwd )

# load helpers
source "${PROJECT_PATH}"/bin/util/echos.sh
source "${PROJECT_PATH}"/bin/util/helpers.sh

# env vars
I2P_LOGLEVEL=${I2P_LOGLEVEL:-none}
DIVA_TESTNET=${DIVA_TESTNET:-0}
IS_TESTNET=${IS_TESTNET:-0}
JOIN_NETWORK=${JOIN_NETWORK:-}
BASE_DOMAIN=${BASE_DOMAIN:-testnet.local}
SIZE_NETWORK=${SIZE_NETWORK:-7}
PURGE=${PURGE:-0}
BASE_IP=${BASE_IP:-172.19.72.}
PORT=${PORT:-17468}
NODE_ENV=${NODE_ENV:-production}
LOG_LEVEL=${LOG_LEVEL:-info}

# Handle joining
if [[ ${DIVA_TESTNET} -gt 0 ]]
then
 JOIN_NETWORK=diva.i2p/testnet
 SIZE_NETWORK=1
 BASE_DOMAIN=testnet.diva.i2p
 IS_TESTNET=1
fi

if [[ -n ${JOIN_NETWORK} ]]
then
 SIZE_NETWORK=1
 BASE_DOMAIN=join.${BASE_DOMAIN}
fi

if ! command_exists docker; then
  error "docker not available. Please install it first.";
  exit 1
fi

if ! command_exists docker compose; then
  error "docker compose not available. Please install it first.";
  exit 2
fi

PATH_DOMAIN=${PROJECT_PATH}/build/domains/${BASE_DOMAIN}
if [[ ! -d ${PATH_DOMAIN} ]]
then
  mkdir "${PATH_DOMAIN}"
  mkdir "${PATH_DOMAIN}"/genesis
  mkdir "${PATH_DOMAIN}"/keys
  mkdir "${PATH_DOMAIN}"/state
  mkdir "${PATH_DOMAIN}"/blockstore
fi
cd "${PATH_DOMAIN}"

if [[ -f ./diva.yml ]]
then
  sudo docker compose -f ./diva.yml down
fi

if [[ ${PURGE} -gt 0 ]]
then
  warn "The confirmation of this action will lead to DATA LOSS!"
  warn "If you want to keep the data, run a backup first."
  confirm "Do you want to DELETE all local diva data and re-create your environment (y/N)?" || exit 3

  if [[ -f ./diva.yml ]]
  then
    sudo docker compose -f ./diva.yml down --volumes
  fi

  sudo rm -rf "${PATH_DOMAIN}"/genesis/*
  sudo rm -rf "${PATH_DOMAIN}"/keys/*
  sudo rm -rf "${PATH_DOMAIN}"/state/*
  sudo rm -rf "${PATH_DOMAIN}"/blockstore/*
fi

if [[ ! -f genesis/local.config ]]
then
  running "Creating Genesis Block using I2P"

  if [[ -f ./genesis-i2p.yml ]]
  then
    sudo SIZE_NETWORK=${SIZE_NETWORK} docker compose -f ./genesis-i2p.yml down --volumes
  fi

  cp "${PROJECT_PATH}"/build/genesis-i2p.yml ./genesis-i2p.yml
  sudo SIZE_NETWORK=${SIZE_NETWORK} docker compose -f ./genesis-i2p.yml pull
  sudo SIZE_NETWORK=${SIZE_NETWORK} docker compose -f ./genesis-i2p.yml up -d

  running "Waiting for key generation"
  # wait until all keys are created
  while [[ ! -f genesis/local.config ]]
  do
    sleep 2
  done

  # shut down the genesis container and clean up
  sudo SIZE_NETWORK=${SIZE_NETWORK} docker compose -f ./genesis-i2p.yml down --volumes
  rm ./genesis-i2p.yml

  # handle joining
  if [[ -n ${JOIN_NETWORK} ]]
  then
    rm -rf ./genesis/block.v7.json
    cp "${PROJECT_PATH}"/build/dummy.block.v7.json ./genesis/block.v7.json
  fi

  ok "Genesis Block successfully created"
fi

running "Creating diva.yml file"

tsc

JOIN_NETWORK=${JOIN_NETWORK} \
  SIZE_NETWORK=${SIZE_NETWORK} \
  BASE_DOMAIN=${BASE_DOMAIN} \
  BASE_IP=${BASE_IP} \
  PORT=${PORT} \
  NODE_ENV=${NODE_ENV} \
  LOG_LEVEL=${LOG_LEVEL} \
  IS_TESTNET=${IS_TESTNET} \
  node "${PROJECT_PATH}"/dist/build.js

ok "Created diva.yml file"
