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
source "${PROJECT_PATH}/bin/util/echos.sh"
source "${PROJECT_PATH}/bin/util/helpers.sh"
source "${PROJECT_PATH}/bin/util/commands.sh"

# env vars
DIVA_TESTNET=${DIVA_TESTNET:-0}
BASE_DOMAIN=${BASE_DOMAIN:-testnet.local}
NO_BOOTSTRAPPING=${NO_BOOTSTRAPPING:-0}

if ! command_exists docker; then
  error "docker not available. Please install it first.";
  exit 1
fi

if ! command_exists docker compose; then
  error "docker compose not available. Please install it first.";
  exit 2
fi

# Handle joining
if [[ ${DIVA_TESTNET} -gt 0 ]]
then
 BASE_DOMAIN=join.testnet.diva.i2p
fi

PATH_DOMAIN=${PROJECT_PATH}/build/domains/${BASE_DOMAIN}
if [[ ! -d ${PATH_DOMAIN} ]]
then
  error "Path not found: ${PATH_DOMAIN}";
  exit 3
fi
cd "${PATH_DOMAIN}"

if [[ ! -f ./diva.yml ]]
then
  error "File not found: ${PATH_DOMAIN}/diva.yml";
  exit 4
fi

running "Pulling ${PATH_DOMAIN}"
as_root docker compose -f ./diva.yml pull

running "Starting ${PATH_DOMAIN}"
NO_BOOTSTRAPPING="${NO_BOOTSTRAPPING}" as_root docker compose -f ./diva.yml up -d
ok "Started ${PATH_DOMAIN}"
