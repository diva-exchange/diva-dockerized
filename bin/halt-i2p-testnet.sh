#!/usr/bin/env bash
#
# Copyright (C) 2020 diva.exchange
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#
# Author/Maintainer: Konrad Bächler <konrad@diva.exchange>
#

# -e Exit immediately if a simple command exits with a non-zero status
set -e

PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd ${PROJECT_PATH}/../

docker-compose -f docker-compose/i2p-testnet.yml down

# clean up, keep i2p volume to preserve keys
docker volume rm \
  postgres.testnet.diva.i2p \
  node.testnet.diva.i2p \
  testnet-a.diva.i2p \
  testnet-b.diva.i2p \
  testnet-c.diva.i2p \
  explorer.testnet.diva.i2p
