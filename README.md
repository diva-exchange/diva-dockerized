# DIVA "Dockerized"

WARNING: **ALPHA software - HIGHLY EXPERIMENTAL**

This project has the following purpose: even if DIVA consists of several independent modules, it still should be easy to have the complete environment available.

## Get Started
Basically there are two options: either join an existing network or create your own.

To start with, it is recommended to join the existing DIVA test network. The test network can be explored on https://testnet.diva.exchange.
  
### Docker Compose
**IMPORTANT**: Make sure you have [Docker Compose](https://docs.docker.com/compose/install/) installed. Check your Docker Compose installation by executing `docker compose version` in a terminal.

### Cloning the Code
If you don't have a GitHub account, create one on github.com. Fork the project to your own GitHub repository.

Then clone the code repository:
```
git clone -b develop-tx https://github.com/YOUR-GITHUB-USERNAME/diva-dockerized.git
cd diva-dockerized
npm i
```

Now, build your own local testnet. 


### Local, I2P based DIVA Test Network
To create an I2P-based DIVA test network, build a local docker compose file first. This is an automated process. Here is an example:
```
BASE_IP=172.19.73. HOST_BASE_IP=127.19.73. bin/build.sh
```

After building the docker compose file, the containers can be **started**:
```
BASE_DOMAIN=testnet.local bin/start.sh
```  

It is now possible to explore the local docker environment using docker commands, like `docker ps -a`.

To **stop** locally running DIVA Test Network containers, execute:
```
BASE_DOMAIN=testnet.local bin/halt.sh
```

### Purge local DIVA data
**Warning** This deletes all your local DIVA data within the folder `build/domains/testnet.local` (keys, blockchain data).

To purge all local data, execute:
```
BASE_DOMAIN=testnet.local bin/purge.sh
```

### Development: Use of Specific Docker Images
It is possible to specify docker images to build the .yml file used by docker compose.
Use the environment variables IMAGE_I2P, IMAGE_CHAIN, IMAGE_PROTOCOL and IMAGE_EXPLORER to pass specific image names to the build process. Here is an example:

```
LOG_LEVEL=trace IMAGE_CHAIN=divax/divachain:develop-tx bin/build.sh
```

This will build a .yml file using a specific docker image as divachain.

## Environment Variables

### DIVA_TESTNET
Boolean: 1 (true) or 0

Default: `0`

### JOIN_NETWORK
String: network entrypoint (bootstrap)

Default: `(empty)` 

### SIZE_NETWORK
Integer, >=7, <=15

Default: `7`

### BASE_DOMAIN
String: valid domain name

Default: `testnet.diva.i2p` 

### HOST_BASE_IP
String: valid local base IP, like 127.19.72. Used to map the docker containers to the host. 

Default: `127.19.72.`

### BASE_IP
String: valid local base IP, like 172.19.72. Used as IP's for docker containers.

Default: `172.19.72.`

### PORT
Integer: >1024, <48000

Default: `17468`

### HAS_EXPLORER
Boolean: 1 (true) or 0

Default: `1`

### HAS_PROTOCOL
Boolean: 1 (true) or 0

Default: `1`

### NODE_ENV
String: production, development

Default: `production`

### LOG_LEVEL
Logging level of NodeJS applications, like divachain

String: trace, info, warn, error, critical

Default: `info`

### PURGE
Boolean: 1 (true) or 0

Default: `0`

### I2P_LOGLEVEL
Logging level of I2P

String: debug, info, warn, error, none

Default: `none`

## Contributions
Contributions are very welcome. This is the general workflow:

1. Fork from https://github.com/diva-exchange/diva-dockerized/
2. Pull the forked project to your local developer environment
3. Make your changes, test, commit and push them
4. Create a new pull request on github.com

It is strongly recommended to sign your commits: https://docs.github.com/en/authentication/managing-commit-signature-verification/telling-git-about-your-signing-key

If you have questions, please just contact us (see below).

## Donations

Your donation goes entirely to the project. Your donation makes the development of DIVA.EXCHANGE faster. Thanks a lot.

### XMR

42QLvHvkc9bahHadQfEzuJJx4ZHnGhQzBXa8C9H3c472diEvVRzevwpN7VAUpCPePCiDhehH4BAWh8kYicoSxpusMmhfwgx

![XMR](https://www.diva.exchange/wp-content/uploads/2020/06/diva-exchange-monero-qr-code-1.jpg)

or via https://www.diva.exchange/en/join-in/

### BTC

3Ebuzhsbs6DrUQuwvMu722LhD8cNfhG1gs

![BTC](https://www.diva.exchange/wp-content/uploads/2020/06/diva-exchange-bitcoin-qr-code-1.jpg)

## Contact the Developers

On [DIVA.EXCHANGE](https://www.diva.exchange) you'll find various options to get in touch with the team.

Talk to us via [Telegram](https://t.me/diva_exchange_chat_de) (English or German).

## License

[AGPLv3](https://github.com/diva-exchange/diva-dockerized/blob/main/LICENSE)
