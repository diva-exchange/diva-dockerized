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

import path from 'path';

export class CreateI2P {
  private readonly joinNetwork: string;
  private readonly sizeNetwork: number = DEFAULT_NETWORK_SIZE;
  private readonly numberInstances: number = DEFAULT_NETWORK_SIZE;
  private readonly baseDomain: string;
  private readonly baseIP: string;
  private readonly port: number;

  constructor(sizeNetwork: number = DEFAULT_NETWORK_SIZE) {
    this.joinNetwork = process.env.JOIN_NETWORK || '';
    this.sizeNetwork = Math.floor(sizeNetwork) > 0 &&
        Math.floor(sizeNetwork) <= MAX_NETWORK_SIZE
      ? Math.floor(sizeNetwork)
      : DEFAULT_NETWORK_SIZE;

    this.numberInstances = this.joinNetwork ? 1 : this.sizeNetwork;

    this.baseDomain = process.env.BASE_DOMAIN || DEFAULT_BASE_DOMAIN;
    this.baseIP = process.env.BASE_IP || DEFAULT_BASE_IP;
    this.port =
      Number(process.env.PORT) > 1024 && Number(process.env.PORT) < 48000
        ? Number(process.env.PORT)
        : DEFAULT_PORT;

    this.createTunnelFile();
    this.createYmlFile();
  }

  private createTunnelFile() {
    let sTunnels = '';
    for (let seq = 1; seq <= this.numberInstances; seq++) {
      const nameI2P = `n${seq}.${this.baseDomain}`;
      sTunnels =
        sTunnels +
        `[${nameI2P}]\n` +
        'type = server\n' +
        `host = ${this.baseIP}${20 + seq}\n` +
        `port = ${this.port}\n` +
        'gzip = false\n' +
        `keys = ${nameI2P}.p2p-api.dat\n\n`;
    }

    const pathTunnelConf = __dirname + `/tunnels.conf.d/${this.baseDomain}/`;
    fs.mkdirSync(pathTunnelConf);
    fs.writeFileSync(pathTunnelConf + 'tunnels.conf', sTunnels);
  }

  private createYmlFile() {
    // docker compose Yml file
    const yml =
      'version: "3.7"\nservices:\n' +
      `  i2p.${this.baseDomain}:\n` +
      `    container_name: i2p.${this.baseDomain}\n` +
      '    image: divax/i2p:latest\n' +
      '    restart: unless-stopped\n' +
      '    environment:\n' +
      '      ENABLE_TUNNELS: 1\n' +
      '    volumes:\n' +
      `      - i2p.${this.baseDomain}:/home/i2pd/data\n` +
      `      - ./tunnels.conf.d/${this.baseDomain}:/home/i2pd/tunnels.source.conf.d\n` +
      '    networks:\n' +
      `      network.${this.baseDomain}:\n` +
      `        ipv4_address: ${this.baseIP}10\n\n` +
      'networks:\n' +
      `  network.${this.baseDomain}:\n` +
      `    name: network.${this.baseDomain}\n` +
      '    ipam:\n' +
      '      driver: default\n' +
      '      config:\n' +
      `        - subnet: ${this.baseIP}0/24\n\n` +
      'volumes:\n' +
      `  i2p.${this.baseDomain}:\n` +
      `    name: i2p.${this.baseDomain}\n`;

    const pathYml = path.join(__dirname, 'i2p.' + this.baseDomain + '.yml');
    fs.writeFileSync(pathYml, yml);
  }
}
