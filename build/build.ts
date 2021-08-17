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

import base64url from 'base64-url';
import fs, { readFileSync } from 'fs';
import path from 'path';
import sodium from 'sodium-native';

import {
  DEFAULT_NETWORK_SIZE,
  MAX_NETWORK_SIZE,
  DEFAULT_BASE_DOMAIN,
  DEFAULT_BASE_IP,
  DEFAULT_PORT,
} from './main';

export class Build {
  private readonly joinNetwork: string;
  private readonly sizeNetwork: number = DEFAULT_NETWORK_SIZE;
  private readonly numberInstances: number = DEFAULT_NETWORK_SIZE;
  private readonly pathGenesis: string;
  private readonly pathKeys: string;
  private readonly baseDomain: string;
  private readonly baseIP: string;
  private readonly port: number;
  private readonly envNode: string;
  private readonly levelLog: string;
  private readonly networkVerboseLogging: number;
  private readonly hasI2P: boolean;
  private readonly mapB32: Map<string, string>;
  private readonly hasExplorer: boolean;

  constructor(sizeNetwork: number = DEFAULT_NETWORK_SIZE) {
    this.joinNetwork = process.env.JOIN_NETWORK || '';

    this.sizeNetwork =
      Math.floor(sizeNetwork) > 0 && Math.floor(sizeNetwork) <= MAX_NETWORK_SIZE
        ? Math.floor(sizeNetwork)
        : DEFAULT_NETWORK_SIZE;

    this.numberInstances = this.joinNetwork ? 1 : this.sizeNetwork;

    this.baseDomain = process.env.BASE_DOMAIN || DEFAULT_BASE_DOMAIN;
    this.baseIP = process.env.BASE_IP || DEFAULT_BASE_IP;
    this.port =
      Number(process.env.PORT) > 1024 && Number(process.env.PORT) < 48000
        ? Number(process.env.PORT)
        : DEFAULT_PORT;
    this.networkVerboseLogging =
      Number(process.env.NETWORK_VERBOSE_LOGGING) > 0 ? 1 : 0;
    this.envNode =
      this.networkVerboseLogging > 0 || process.env.NODE_ENV === 'development'
        ? 'development'
        : 'production';
    this.levelLog = process.env.LOG_LEVEL || 'warn';

    const genesisFileName = this.baseDomain.replace(
        /[^a-z0-9\._-]|^[\._-]+|[\._-]+$/gi,
        ''
    );
    this.pathGenesis = path.join(__dirname, `genesis/${genesisFileName}.json`);
    this.pathKeys = path.join(__dirname, 'keys');

    this.hasI2P = Number(process.env.HAS_I2P) > 0;
    this.mapB32 = new Map();
    if (this.hasI2P) {
      this.createB32Map();
    }

    this.hasExplorer = Number(process.env.HAS_EXPLORER || 1) > 0;

    this.createFiles();
  }

  private createB32Map() {
    const s = readFileSync(
      path.join(__dirname, 'b32', this.baseDomain)
    ).toString();
    const re = new RegExp(
      'b32=([a-z2-7]+)">([^.]+.' + this.baseDomain + ')',
      'g'
    );
    for (const a of [...s.matchAll(re)]) {
      this.mapB32.set(a[2], a[1] + '.b32.i2p');
    }
  }

  private createFiles() {
    // genesis block
    const genesis: any = JSON.parse(
      fs.readFileSync(path.join(__dirname, '../genesis/block.json')).toString()
    );
    const commands: Array<object> = [];
    let seq = 1;

    fs.mkdirSync(path.join(this.pathKeys, this.baseDomain));

    for (let t = 1; t <= this.numberInstances; t++) {
      const host = this.hasI2P
        ? `n${t}.${this.baseDomain}`
        : `${this.baseIP}${20 + t}`;
      const port = this.port.toString();
      const ident = (
        (this.mapB32.get(host) || `${this.baseIP}${20 + t}`) + `:${port}`
      ).replace(/[^a-z0-9_-]+/gi, '-');

      const _publicKey: Buffer = sodium.sodium_malloc(
        sodium.crypto_sign_PUBLICKEYBYTES
      );
      const _secretKey: Buffer = sodium.sodium_malloc(
        sodium.crypto_sign_SECRETKEYBYTES
      );
      sodium.sodium_mlock(_secretKey);
      try {
        sodium.crypto_sign_keypair(_publicKey, _secretKey);
        fs.writeFileSync(
          path.join(this.pathKeys, this.baseDomain, ident + '.secret'),
          _secretKey,
          { mode: '0600' }
        );
      } finally {
        sodium.sodium_munlock(_secretKey);
      }

      const publicKey = base64url.escape(_publicKey.toString('base64'));
      fs.writeFileSync(
        path.join(this.pathKeys, this.baseDomain, ident + '.public'),
        publicKey
      );

      commands.push({
        seq: seq,
        command: 'addPeer',
        host: this.mapB32.get(host) || host,
        port: Number(port),
        publicKey: publicKey,
      });
      seq++;
      commands.push({
        seq: seq,
        command: 'modifyStake',
        publicKey: publicKey,
        stake: 1000,
      });
      seq++;
    }

    genesis.tx = [
      {
        ident: 'genesis',
        origin: '0000000000000000000000000000000000000000000',
        timestamp: 88355100000,
        commands: commands,
        sig: '00000000000000000000000000000000000000000000000000000000000000000000000000000000000000',
      },
    ];

    fs.writeFileSync(this.pathGenesis, JSON.stringify(genesis));

    // docker compose Yml file
    let yml = 'version: "3.7"\nservices:\n';
    let volumes = '';
    if (this.hasI2P) {
      yml =
        yml +
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
        `        ipv4_address: ${this.baseIP}10\n\n`;
      volumes =
        volumes +
        `  i2p.${this.baseDomain}:\n    name: i2p.${this.baseDomain}\n`;
    }

    if (this.hasExplorer) {
      yml =
        yml +
        `  explorer.${this.baseDomain}:\n` +
        `    container_name: explorer.${this.baseDomain}\n` +
        '    image: divax/explorer:latest\n' +
        '    restart: unless-stopped\n' +
        '    environment:\n' +
        `      HTTP_IP: ${this.baseIP}11\n` +
        '      HTTP_PORT: 3920\n' +
        `      URL_API: http://${this.baseIP}21:${this.port}\n` +
        '    networks:\n' +
        `      network.${this.baseDomain}:\n` +
        `        ipv4_address: ${this.baseIP}11\n\n`;
    }

    for (let seq = 1; seq <= this.numberInstances; seq++) {
      const hostChain = this.hasI2P
        ? `n${seq}.${this.baseDomain}`
        : `${this.baseIP}${20 + seq}`;
      const nameChain = `n${seq}.chain.${this.baseDomain}`;
      let proxy = '';
      if (this.hasI2P) {
        proxy =
          `      I2P_SOCKS_PROXY_HOST: ${this.baseIP}10\n` +
          '      I2P_SOCKS_PROXY_PORT: 4445\n      I2P_SOCKS_PROXY_CONSOLE_PORT: 7070\n';
      }

      const address = this.mapB32.get(hostChain) || `${this.baseIP}${20 + seq}`;
      yml =
        yml +
        `  ${nameChain}:\n` +
        `    container_name: ${nameChain}\n` +
        '    image: divax/divachain:latest\n' +
        '    restart: unless-stopped\n' +
        '    environment:\n' +
        `      NAME_BLOCK_GENESIS: ${this.baseDomain}\n` +
        `      NODE_ENV: ${this.envNode}\n` +
        `      LOG_LEVEL: ${this.levelLog}\n` +
        `      IP: ${this.baseIP}${20 + seq}\n` +
        `      PORT: ${this.port}\n` +
        `      ADDRESS: ${address}:${this.port}\n` +
        proxy +
        `      BOOTSTRAP: ${
          this.joinNetwork ? 'http://' + this.joinNetwork : ''
        }\n` +
        `      NETWORK_SIZE: ${this.sizeNetwork}\n` +
        `      NETWORK_VERBOSE_LOGGING: ${this.networkVerboseLogging}\n` +
        '    volumes:\n' +
        `      - ${nameChain}-blockstore:/blockstore\n` +
        `      - ${nameChain}-state:/state\n` +
        `      - ./keys/${this.baseDomain}:/keys\n` +
        '      - ./genesis:/genesis\n' +
        '    networks:\n' +
        `      network.${this.baseDomain}:\n` +
        `        ipv4_address: ${this.baseIP}${20 + seq}\n\n`;
      volumes =
        volumes +
        `  ${nameChain}-blockstore:\n    name: ${nameChain}-blockstore\n` +
        `  ${nameChain}-state:\n    name: ${nameChain}-state\n`;
    }

    yml =
      yml +
      'networks:\n' +
      `  network.${this.baseDomain}:\n` +
      `    name: network.${this.baseDomain}\n` +
      '    ipam:\n' +
      '      driver: default\n' +
      '      config:\n' +
      `        - subnet: ${this.baseIP}0/24\n\n` +
      (volumes ? 'volumes:\n' + volumes : '');

    const pathYml = path.join(__dirname, this.baseDomain + '.yml');
    fs.writeFileSync(pathYml, yml);
  }
}
