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

DOMAIN=${DOMAIN:-testnet.diva.i2p}

LEAVE_INSTANCE=${LEAVE_INSTANCE:0}

for nameFile in `ls -1 ${PROJECT_PATH}data/ | fgrep ".${DOMAIN}"`
do
  INSTANCE=$(<${PROJECT_PATH}data/${nameFile})
  if [[ ${LEAVE_INSTANCE} -gt 0 && ! ${LEAVE_INSTANCE} -eq ${INSTANCE} ]]
  then
    continue
  fi
  rm -f ${PROJECT_PATH}data/${nameFile}
  IDENT=nx${INSTANCE}

  NAME_NETWORK=${IDENT}.net.${DOMAIN}
  NAME_I2P=${IDENT}.i2p.${DOMAIN}
  NAME_IROHA=${IDENT}.${DOMAIN}
  NAME_DB=${IDENT}.db.${DOMAIN}
  NAME_API=${IDENT}.api.${DOMAIN}

  # api
  echo "Stopping API ${NAME_API}..."
  [[ `docker ps | fgrep ${NAME_API}` ]] && docker stop ${NAME_API} >/dev/null
  [[ `docker ps -a | fgrep ${NAME_API}` ]] && docker rm ${NAME_API} >/dev/null
  echo "Removing API volume ${NAME_API}..."
  [[ `docker volume ls | fgrep ${NAME_API}` ]] && docker volume rm ${NAME_API} >/dev/null

  # postgres and iroha container
  echo "Stopping Iroha ${NAME_IROHA}..."
  [[ `docker ps | fgrep ${NAME_IROHA}` ]] && docker stop ${NAME_IROHA} >/dev/null
  [[ `docker ps -a | fgrep ${NAME_IROHA}` ]] && docker rm ${NAME_IROHA} >/dev/null

  echo "Stopping DB ${NAME_DB}..."
  [[ `docker ps | fgrep ${NAME_DB}` ]] && docker stop ${NAME_DB} >/dev/null
  [[ `docker ps -a | fgrep ${NAME_DB}` ]] && docker rm ${NAME_DB} >/dev/null
  echo "Removing DB volume ${NAME_DB}..."
  [[ `docker volume ls | fgrep ${NAME_DB}` ]] && docker volume rm ${NAME_DB} >/dev/null

  # i2p
  echo "Stopping ${NAME_I2P}..."
  [[ `docker ps | fgrep ${NAME_I2P}` ]] && docker stop ${NAME_I2P} >/dev/null
  [[ `docker ps -a | fgrep ${NAME_I2P}` ]] && docker rm ${NAME_I2P} >/dev/null

  #network
  echo "Removing network ${NAME_NETWORK}..."
  [[ `docker network ls | fgrep ${NAME_NETWORK}` ]] && docker network rm ${NAME_NETWORK} >/dev/null

done
