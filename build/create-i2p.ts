/**
 * Copyright (C) 2021 diva.exchange
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 * Author/Maintainer: Konrad Bächler <konrad@diva.exchange>
 */

import fs from 'fs';

import {
  DEFAULT_NETWORK_SIZE,
  MAX_NETWORK_SIZE,
  DEFAULT_BASE_IP,
  DEFAULT_PORT,
  DEFAULT_BASE_DOMAIN,
} from './main';

export class CreateI2P {
  private readonly joinNetwork: string;
  private readonly sizeNetwork: number = DEFAULT_NETWORK_SIZE;
  private readonly baseDomain: string;
  private readonly baseIP: string;
  private readonly port: number;

  constructor(sizeNetwork: number = DEFAULT_NETWORK_SIZE) {
    this.joinNetwork = process.env.JOIN_NETWORK || '';
    this.sizeNetwork = this.joinNetwork
      ? 1
      : Math.floor(sizeNetwork) > 0 &&
        Math.floor(sizeNetwork) <= MAX_NETWORK_SIZE
      ? Math.floor(sizeNetwork)
      : DEFAULT_NETWORK_SIZE;

    this.baseDomain = process.env.BASE_DOMAIN || DEFAULT_BASE_DOMAIN;
    this.baseIP = process.env.BASE_IP || DEFAULT_BASE_IP;
    this.port =
      Number(process.env.PORT) > 1024 && Number(process.env.PORT) < 48000
        ? Number(process.env.PORT)
        : DEFAULT_PORT;

    this.createTunnelFile();
  }

  private createTunnelFile() {
    let sTunnels = '';
    for (let seq = 1; seq <= this.sizeNetwork; seq++) {
      const nameI2P = `n${seq}.${DEFAULT_BASE_DOMAIN}`;
      sTunnels =
        sTunnels +
        `[${nameI2P}]\n` +
        'type = server\n' +
        `host = ${this.baseIP}${20 + seq}\n` +
        `port = ${this.port}\n` +
        'gzip = false\n' +
        `keys = ${nameI2P}.p2p-api.dat\n\n`;
    }

    fs.writeFileSync(
      __dirname + `/tunnels.conf.d/${this.baseDomain}.conf`,
      sTunnels
    );
  }
}
