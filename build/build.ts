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
import path from 'path';
import {
  DEFAULT_BASE_DOMAIN,
  DEFAULT_BASE_IP,
  DEFAULT_PORT,
  DEFAULT_BLOCK_FEED_PORT,
  DEFAULT_UI_PORT,
  DEFAULT_PROTOCOL_PORT,
} from './main';
import { toB32 } from '@diva.exchange/i2p-sam';

export class Build {
  static make() {
    const image_i2p = process.env.IMAGE_I2P || 'divax/i2p:latest';
    const image_chain = process.env.IMAGE_CHAIN || 'divax/divachain:latest';
    const image_protocol =
      process.env.IMAGE_PROTOCOL || 'divax/divaprotocol:latest';
    const image_explorer =
      process.env.IMAGE_EXPLORER || 'divax/explorer:latest';

    const joinNetwork = process.env.JOIN_NETWORK || '';

    const baseDomain = process.env.BASE_DOMAIN || DEFAULT_BASE_DOMAIN;
    const baseIP = process.env.BASE_IP || DEFAULT_BASE_IP;
    const port =
      Number(process.env.PORT) > 1024 && Number(process.env.PORT) < 48000
        ? Number(process.env.PORT)
        : DEFAULT_PORT;
    const port_block_feed =
      Number(process.env.BLOCK_FFED_PORT) > 1024 &&
      Number(process.env.BLOCK_FFED_PORT) < 48000
        ? Number(process.env.BLOCK_FFED_PORT)
        : DEFAULT_BLOCK_FEED_PORT;
    const port_ui =
      Number(process.env.UI_PORT) > 1024 && Number(process.env.UI_PORT) < 48000
        ? Number(process.env.UI_PORT)
        : DEFAULT_UI_PORT;
    const port_protocol =
      Number(process.env.PORT_PROTOCOL) > 1024 &&
      Number(process.env.PORT_PROTOCOL) < 48000
        ? Number(process.env.PORT_PROTOCOL)
        : DEFAULT_PROTOCOL_PORT;
    const envNode =
      process.env.NODE_ENV === 'development' ? 'development' : 'production';
    const levelLog = process.env.LOG_LEVEL || 'warn';

    const hasExplorer = Number(process.env.HAS_EXPLORER || 1) > 0;
    const hasProtocol = Number(process.env.HAS_PROTOCOL || 1) > 0;

    // docker compose Yml file
    let yml = 'version: "3.7"\nservices:\n';
    let volumes = '';
    // http
    yml =
      yml +
      `  i2p.http.${baseDomain}:\n` +
      `    container_name: i2p.http.${baseDomain}\n` +
      `    image: ${image_i2p}\n` +
      '    restart: unless-stopped\n' +
      '    environment:\n' +
      '      ENABLE_SOCKSPROXY: 1\n' +
      '      ENABLE_SAM: 1\n' +
      '      BANDWIDTH: P\n' +
      '    volumes:\n' +
      `      - i2p.http.${baseDomain}:/home/i2pd/data\n` +
      '    networks:\n' +
      `      network.${baseDomain}:\n` +
      `        ipv4_address: ${baseIP}11\n\n`;
    volumes =
      volumes +
      `  i2p.http.${baseDomain}:\n    name: i2p.http.${baseDomain}\n`;

    // udp
    yml =
      yml +
      `  i2p.udp.${baseDomain}:\n` +
      `    container_name: i2p.udp.${baseDomain}\n` +
      `    image: ${image_i2p}\n` +
      '    restart: unless-stopped\n' +
      '    environment:\n' +
      '      ENABLE_SAM: 1\n' +
      '      BANDWIDTH: P\n' +
      '    volumes:\n' +
      `      - i2p.udp.${baseDomain}:/home/i2pd/data\n` +
      '    networks:\n' +
      `      network.${baseDomain}:\n` +
      `        ipv4_address: ${baseIP}12\n\n`;
    volumes =
      volumes + `  i2p.udp.${baseDomain}:\n    name: i2p.udp.${baseDomain}\n`;

    if (hasExplorer) {
      yml =
        yml +
        `  explorer.${baseDomain}:\n` +
        `    container_name: explorer.${baseDomain}\n` +
        `    image: ${image_explorer}\n` +
        '    restart: unless-stopped\n' +
        '    environment:\n' +
        `      HTTP_IP: ${baseIP}200\n` +
        `      HTTP_PORT: ${port_ui}\n` +
        `      URL_API: http://${baseIP}21:${port}\n` +
        `      URL_FEED: ws://${baseIP}21:${port_block_feed}\n` +
        '    ports:\n' +
        `      - ${port_ui}:${port_ui}\n` +
        '    networks:\n' +
        `      network.${baseDomain}:\n` +
        `        ipv4_address: ${baseIP}200\n\n`;
    }

    const pathConfig = path.join(__dirname, 'genesis', 'local.config');
    const mapConfig = new Map(
      JSON.parse(fs.readFileSync(pathConfig).toString())
    );

    let seq = 1;
    mapConfig.forEach((config: any) => {
      const nameChain = `n${seq}.chain.${baseDomain}`;

      const proxy =
        `      I2P_SOCKS_HOST: ${baseIP}11\n` +
        `      I2P_SAM_HTTP_HOST: ${baseIP}11\n` +
        `      I2P_SAM_FORWARD_HTTP_HOST: ${baseIP}${20 + seq}\n` +
        `      I2P_SAM_FORWARD_HTTP_PORT: ${port}\n` +
        `      I2P_SAM_UDP_HOST: ${baseIP}12\n` +
        `      I2P_SAM_LISTEN_UDP_HOST: ${baseIP}${20 + seq}\n` +
        `      I2P_SAM_LISTEN_UDP_PORT: ${port + 2}\n` +
        `      I2P_SAM_FORWARD_UDP_HOST: ${baseIP}${20 + seq}\n` +
        `      I2P_SAM_FORWARD_UDP_PORT: ${port + 2}\n`;

      const http = toB32(config.http) + '.b32.i2p';
      const udp = toB32(config.udp) + '.b32.i2p';

      yml =
        yml +
        `  ${nameChain}:\n` +
        `    container_name: ${nameChain}\n` +
        `    image: ${image_chain}\n` +
        '    restart: unless-stopped\n' +
        '    environment:\n' +
        `      NODE_ENV: ${envNode}\n` +
        `      LOG_LEVEL: ${levelLog}\n` +
        `      IP: ${baseIP}${20 + seq}\n` +
        `      PORT: ${port}\n` +
        `      BLOCK_FEED_PORT: ${port + 1}\n` +
        `      HTTP: ${http}\n` +
        `      UDP: ${udp}\n` +
        proxy +
        (joinNetwork
          ? `      BOOTSTRAP: http://${joinNetwork}\n` +
            '      NO_BOOTSTRAPPING: ${NO_BOOTSTRAPPING:-0}\n'
          : '') +
        '    volumes:\n' +
        `      - ${nameChain}-blockstore:/blockstore\n` +
        `      - ${nameChain}-state:/state\n` +
        '      - ../keys:/keys\n' +
        '      - ../genesis:/genesis\n' +
        '    networks:\n' +
        `      network.${baseDomain}:\n` +
        `        ipv4_address: ${baseIP}${20 + seq}\n\n`;
      volumes =
        volumes +
        `  ${nameChain}-blockstore:\n    name: ${nameChain}-blockstore\n` +
        `  ${nameChain}-state:\n    name: ${nameChain}-state\n`;

      // protocol
      if (hasProtocol) {
        const nameProtocol = `n${seq}.protocol.${baseDomain}`;

        yml =
          yml +
          `  ${nameProtocol}:\n` +
          `    container_name: ${nameProtocol}\n` +
          `    image: ${image_protocol}\n` +
          '    restart: unless-stopped\n' +
          '    environment:\n' +
          `      NODE_ENV: ${envNode}\n` +
          `      LOG_LEVEL: ${levelLog}\n` +
          `      IP: ${baseIP}${120 + seq}\n` +
          `      PORT: ${port_protocol}\n` +
          `      URL_API_CHAIN: http://${baseIP}${20 + seq}:${port}\n` +
          `      URL_BLOCK_FEED: ws://${baseIP}${
            20 + seq
          }:${port_block_feed}\n` +
          '    networks:\n' +
          `      network.${baseDomain}:\n` +
          `        ipv4_address: ${baseIP}${120 + seq}\n\n`;
      }

      seq++;
    });

    yml =
      yml +
      'networks:\n' +
      `  network.${baseDomain}:\n` +
      `    name: network.${baseDomain}\n` +
      '    ipam:\n' +
      '      driver: default\n' +
      '      config:\n' +
      `        - subnet: ${baseIP}0/24\n\n` +
      (volumes ? 'volumes:\n' + volumes : '');

    const pathYml = path.join(__dirname, 'yml', baseDomain + '.yml');
    fs.writeFileSync(pathYml, yml);
  }
}
