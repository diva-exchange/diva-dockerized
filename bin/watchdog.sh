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

NODE=${NODE:-0}
IDENT=${NODE}.testnet.diva.i2p
if [[ `docker inspect ${IDENT} >/dev/null 2>&1 ; echo $?` -gt 0 ]]
then
  echo "Node ${IDENT} not running"
  exit 1
fi

echo "Watching ${IDENT}..."
sleep 600

while [[ `docker inspect ${IDENT} >/dev/null 2>&1 ; echo $?` -eq 0 ]]
do
  sleep 60
  DT=`stat -c %y /var/lib/docker/volumes/${IDENT}/_data/blockstore`
  echo `date` : ${DT}
  if [[ `date -d "${DT}" +%s` -lt $((`date +%s`-240)) ]]
  then
    echo "Restarting ${IDENT}..."
    ${PROJECT_PATH}bin/restart-node.sh
    sleep 600
  fi
done
