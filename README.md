# DIVA.EXCHANGE "Dockerized"

This project has the following purpose: even if DIVA.EXCHANGE consists of several independent modules, it still should be easy to have the complete environment available.

Online Demo and Test sites:
* https://testnet.diva.exchange - The public DIVA.EXCHANGE testnet. Everybody can join.

It's licenced under [AGPLv3](LICENSE).


## Get Started

There are two different flavours of testnets available: a simple local one and an I2P-based one.

**Local:** the local testnet runs on your local network. It's fast and available on your local network only. Use it for application development.

**Private (I2P):** the I2P based testnet routes all traffic between the DIVACHAIN nodes through the I2P network. The DIVACHAIN nodes itself remain private. The I2P network might have quite some latency.

### Docker Compose & Clone the Code

**IMPORTANT**: To start a local DIVA testnet, make sure you have [Docker Compose](https://docs.docker.com/compose/install/) installed. Check your Docker Compose installation by executing `docker-compose --version` in a terminal.

Clone the code repository from the public repository:
```
git clone https://codeberg.org/diva.exchange/diva-dockerized.git
cd diva-dockerized
```

Either build your own local testnet or join the existing [DIVACHAIN testnet](https://testnet.diva.exchange). 

### Join the DIVACHAIN Test Network

To join the DIVACHAIN test network, build a local docker compose file first. This is an automated process. Here is an example on how to join the DIVACHAIN test network via I2P (it will ask for the root password, since it has to access docker):
```
HAS_I2P=1 JOIN_NETWORK=diva.i2p/testnet BASE_IP=172.19.72. bin/build.sh
```

After building the docker compose file, the containers can be **started**:
```
bin/start.sh
```  

It is now possible to explore the local docker environment using docker commands, like `docker ps -a`.

To **stop** locally running DIVACHAIN Test Network containers, execute:
```
bin/stop.sh
```

### Leave the DIVACHAIN Network

tbd.

### Local DIVACHAIN Testnet

To create a local DIVACHAIN test network, build a local docker compose file first. This is an automated process. Here is an example:
```
BASE_IP=172.19.73. bin/build.sh
```

After building the docker compose file, the containers can be **started**:
```
bin/start.sh
```  

It is now possible to explore the local docker environment using docker commands, like `docker ps -a`.

To **stop** locally running DIVACHAIN Test Network containers, execute:
```
bin/stop.sh
```

### I2P based DIVACHAIN Testnet

To create an I2P-based DIVACHAIN test network, build a local docker compose file first. This is an automated process. Here is an example:
```
HAS_I2P=1 BASE_IP=172.19.73. bin/build.sh
```

After building the docker compose file, the containers can be **started**:
```
bin/start.sh
```  

It is now possible to explore the local docker environment using docker commands, like `docker ps -a`.

To **stop** locally running DIVACHAIN Test Network containers, execute:
```
bin/stop.sh
```

### Purge local DIVACHAIN data

To purge all local data, execute:
```
bin/purge.sh
```

## Environment Variables

### JOIN_NETWORK
String: network entrypoint (bootstrap)

Default: `(empty)` 

### SIZE_NETWORK
Integer, >=7, <=64

Default: `7`

### BASE_DOMAIN
String: valid domain name

Default: `testnet.diva.i2p` 

### BASE_IP
String: valid local base IP, like 172.19.72.

Default: `172.19.72.`

### PORT
Integer: >1024, < 48000

Default: `17468`

### HAS_I2P
Boolean: 1 (true) or 0

Default: `0`

### NODE_ENV
String: production, development

Default: `production`

### LOG_LEVEL
String: trace, info, warn, error, critical

Default: `trace`

### NETWORK_VERBOSE_LOGGING
Boolean: 1 (true) or 0

Default: `0`

## Contact the Developers

On [DIVA.EXCHANGE](https://www.diva.exchange) you'll find various options to get in touch with the team.

Talk to us via Telegram [https://t.me/diva_exchange_chat_de]() (English or German).

## Donations

Your donation goes entirely to the project. Your donation makes the development of DIVA.EXCHANGE faster.

XMR: 42QLvHvkc9bahHadQfEzuJJx4ZHnGhQzBXa8C9H3c472diEvVRzevwpN7VAUpCPePCiDhehH4BAWh8kYicoSxpusMmhfwgx

BTC: 3Ebuzhsbs6DrUQuwvMu722LhD8cNfhG1gs

Awesome, thank you!

## License

[AGPLv3](LICENSE)
