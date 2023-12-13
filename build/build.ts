/**
 * Copyright (C) 2021-2023 diva.exchange
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
 * Author/Maintainer: DIVA.EXCHANGE Association, https://diva.exchange
 */

import fs from 'fs';
import { toB32 } from '@diva.exchange/i2p-sam';

const DEFAULT_I2P_LOGLEVEL = 'none';
const DEFAULT_BASE_DOMAIN = 'testnet.diva.i2p';
const DEFAULT_HOST_BASE_IP = '127.19.72.';
const DEFAULT_BASE_IP = '172.19.72.';
const DEFAULT_PORT = 17468;
const DEFAULT_BLOCK_FEED_PORT = 17469;
const DEFAULT_UI_PORT = 3920;
const DEFAULT_PROTOCOL_PORT = 19720;

class Build {
  static make() {
    const loglevel_i2p = process.env.I2P_LOGLEVEL || DEFAULT_I2P_LOGLEVEL;
    const image_i2p = process.env.IMAGE_I2P || 'divax/i2p:current';
    const image_chain = process.env.IMAGE_CHAIN || 'divax/divachain:latest';
    const image_protocol =
      process.env.IMAGE_PROTOCOL || 'divax/divaprotocol:latest';
    const image_explorer =
      process.env.IMAGE_EXPLORER || 'divax/explorer:current';

    const isTestnet = process.env.IS_TESTNET || '0';
    const joinNetwork = process.env.JOIN_NETWORK || '';

    const baseDomain = process.env.BASE_DOMAIN || DEFAULT_BASE_DOMAIN;
    const hostBaseIP = process.env.HOST_BASE_IP || DEFAULT_HOST_BASE_IP;
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
      '      ENABLE_HIDDEN: 1\n' +
      '      BANDWIDTH: P\n' +
      `      LOGLEVEL: ${loglevel_i2p}\n` +
      '    volumes:\n' +
      `      - i2p.http.${baseDomain}:/home/i2pd/data\n` +
      '    ports:\n' +
      `      - ${hostBaseIP}11:7070:7070\n` +
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
      '      ENABLE_HIDDEN: 1\n' +
      '      BANDWIDTH: P\n' +
      `      LOGLEVEL: ${loglevel_i2p}\n` +
      '    volumes:\n' +
      `      - i2p.udp.${baseDomain}:/home/i2pd/data\n` +
      '    ports:\n' +
      `      - ${hostBaseIP}12:7070:7070\n` +
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
        '    depends_on:\n' +
        `      - n1.chain.${baseDomain}\n` +
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

    const arrayConfig = JSON.parse(fs.readFileSync('genesis/local.config').toString());

    let seq = 1;
    arrayConfig.forEach((config: any) => {
      const nameChain = `n${seq}.chain.${baseDomain}`;

      const http = toB32(config.http) + '.b32.i2p';
      const udp = toB32(config.udp) + '.b32.i2p';

      yml =
        yml +
        `  ${nameChain}:\n` +
        `    container_name: ${nameChain}\n` +
        `    image: ${image_chain}\n` +
        '    depends_on:\n' +
        `      - i2p.http.${baseDomain}\n` +
        `      - i2p.udp.${baseDomain}\n` +
        '    restart: unless-stopped\n' +
        '    environment:\n' +
        `      NODE_ENV: ${envNode}\n` +
        `      IS_TESTNET: ${isTestnet}\n` +
        `      LOG_LEVEL: ${levelLog}\n` +
        `      IP: ${baseIP}${20 + seq}\n` +
        `      PORT: ${port}\n` +
        `      BLOCK_FEED_PORT: ${port + 1}\n` +
        `      HTTP: ${http}\n` +
        `      UDP: ${udp}\n` +
        `      I2P_SOCKS_HOST: ${baseIP}11\n` +
        `      I2P_SAM_HTTP_HOST: ${baseIP}11\n` +
        `      I2P_SAM_FORWARD_HTTP_HOST: ${baseIP}${20 + seq}\n` +
        `      I2P_SAM_FORWARD_HTTP_PORT: ${port}\n` +
        `      I2P_SAM_UDP_HOST: ${baseIP}12\n` +
        `      I2P_SAM_LISTEN_UDP_HOST: ${baseIP}${20 + seq}\n` +
        `      I2P_SAM_LISTEN_UDP_PORT: ${port + 2}\n` +
        `      I2P_SAM_FORWARD_UDP_HOST: ${baseIP}${20 + seq}\n` +
        `      I2P_SAM_FORWARD_UDP_PORT: ${port + 2}\n` +
        (joinNetwork
          ? `      BOOTSTRAP: http://${joinNetwork}\n` +
            '      NO_BOOTSTRAPPING: ${NO_BOOTSTRAPPING:-0}\n'
          : '') +
        '    volumes:\n' +
        '      - ./blockstore:/blockstore\n' +
        '      - ./state:/state\n' +
        '      - ./keys:/keys\n' +
        '      - ./genesis:/genesis\n' +
        '    ports:\n' +
        `      - ${hostBaseIP}${20 + seq}:${port}:${port}\n` +
        '    networks:\n' +
        `      network.${baseDomain}:\n` +
        `        ipv4_address: ${baseIP}${20 + seq}\n\n`;

      // protocol
      if (hasProtocol) {
        const nameProtocol = `n${seq}.protocol.${baseDomain}`;

        yml =
          yml +
          `  ${nameProtocol}:\n` +
          `    container_name: ${nameProtocol}\n` +
          `    image: ${image_protocol}\n` +
          '    depends_on:\n' +
          `      - ${nameChain}\n` +
          '    restart: unless-stopped\n' +
          '    environment:\n' +
          `      NODE_ENV: ${envNode}\n` +
          `      LOG_LEVEL: ${levelLog}\n` +
          `      IP: ${baseIP}${120 + seq}\n` +
          `      PORT: ${port_protocol}\n` +
          `      URL_API_CHAIN: http://${baseIP}${20 + seq}:${port}\n` +
          `      URL_BLOCK_FEED: ws://${baseIP}${20 + seq}:${port_block_feed}\n` +
          '    ports:\n' +
          `      - ${hostBaseIP}${120 + seq}:${port_protocol}:${port_protocol}\n` +
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

    fs.writeFileSync('diva.yml', yml);
  }
}

Build.make();
