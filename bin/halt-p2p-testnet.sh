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

# -a Export variables
set -a

PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/../"
cd ${PROJECT_PATH}

# used to store temporary data related to running containers
DATA_PATH=${PROJECT_PATH}data/

if [[ ! -f ${DATA_PATH}instance ]]
then
  exit 1
fi

[[ $(docker inspect iroha-node 2>/dev/null | wc -l) > 1 ]] && \
  docker stop iroha-node && \
  docker rm iroha-node

# remove iroha-node volume
docker volume rm iroha-node -f

for (( ID_INSTANCE=1; ID_INSTANCE < $(<${DATA_PATH}instance); ID_INSTANCE++ ))
do
  [[ $(docker inspect iroha${ID_INSTANCE} 2>/dev/null | wc -l) > 1 ]] && \
    docker stop iroha${ID_INSTANCE} && \
    docker rm iroha${ID_INSTANCE}

  # remove iroha volume
  docker volume rm iroha${ID_INSTANCE} -f
done

# remove instance file
rm -f ${DATA_PATH}instance
