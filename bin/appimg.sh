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

set -eu

RDNS_NAME="exchange.diva.divachain"

PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"/../
cd "${PROJECT_PATH}"
PROJECT_PATH=$( pwd )
APP_DIR="$PROJECT_PATH/build/$RDNS_NAME.AppDir"

# load helpers
source "${PROJECT_PATH}"/bin/util/echos.sh
source "${PROJECT_PATH}"/bin/util/helpers.sh
source "${PROJECT_PATH}"/bin/util/commands.sh

# DIVA_TESTNET=1 "$PROJECT_PATH"/bin/build.sh

grab_i2pd_build() {
    I2PD_LIBS=(
        /usr/lib/libboost_filesystem.so.1.78.0
        /usr/lib/libboost_program_options.so.1.78.0
        /lib/libssl.so.1.1
        /lib/libcrypto.so.1.1
        /usr/lib/libminiupnpc.so.17
        /lib/libz.so.1
        /usr/lib/libstdc++.so.6
        /usr/lib/libgcc_s.so.1
        /lib/libc.musl-x86_64.so.1
        /lib/ld-musl-x86_64.so.1
    )

    id=$(docker create divax/i2p:current)
    docker cp -L $id:/home/i2pd "$APP_DIR/opt/"
    docker cp -L $id:/bin/sh "$APP_DIR/bin/"


    for lib in "${I2PD_LIBS[@]}"; do
        docker cp -L "$id:$lib" "$APP_DIR/opt/i2pd/$lib"
    done
    docker rm -v "$id"

    for binary in "$APP_DIR/opt/i2pd/bin/i2pd" "$APP_DIR/bin/sh"; do
        patchelf --debug --set-interpreter ./opt/i2pd/lib/ld-musl-x86_64.so.1 "$binary"
    done
}

grab_divachain_build() {
    DIVACHAIN_LIBS=(
        /lib/x86_64-linux-gnu/libdl.so.2
        /usr/lib/x86_64-linux-gnu/libstdc++.so.6
        /lib/x86_64-linux-gnu/libm.so.6
        /lib/x86_64-linux-gnu/libpthread.so.0
        /lib/x86_64-linux-gnu/libc.so.6
        /lib64/ld-linux-x86-64.so.2
    )


    id=$(docker create divax/divachain:latest)
    docker cp -L "$id:/divachain" "$APP_DIR/usr/bin/divachain"
    for f in bin etc genesis keys package.json; do
        docker cp -L "$id:/$f" "$APP_DIR/"
    done

    set -x

    for lib in "${DIVACHAIN_LIBS[@]}"; do
        docker cp -L "$id:$lib" "$APP_DIR/$lib"
    done


    docker rm -v "$id"

    USED_BINARIES=(
       "$APP_DIR"/lib/x86_64-linux-gnu/libc.so.6
       "$APP_DIR/bin/divachain"
    )
    for binary in "${USED_BINARIES[@]}"; do

        ft="$(file "$binary")"

        if [[ "$ft"  =~ ": ELF " ]]; then
            patchelf --set-interpreter ./lib64/ld-linux-x86-64.so.2 "$binary"
        else
            echo "WARNING: $binary is not a binary and therefore cannot be patched"
        fi
    done
}

grab_i2pd_build

grab_divachain_build

appimagetool "$APP_DIR" build/divachain.AppImage
