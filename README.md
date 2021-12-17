# DIVA.EXCHANGE "Dockerized"

This project has the following purpose: even if DIVA.EXCHANGE consists of several independent modules, it still should be easy to have the complete environment available.

Online Demo and Test sites:
* https://testnet.diva.exchange - The public DIVA.EXCHANGE testnet. Everybody can join.

It's licenced under [AGPLv3](LICENSE).


## Get Started

Basically there are two options: either join an existing network or create your own.
  
### Docker Compose & Clone the Code

**IMPORTANT**: To start a local DIVA testnet, make sure you have [Docker Compose](https://docs.docker.com/compose/install/) installed. Check your Docker Compose installation by executing `docker-compose --version` in a terminal.

Clone the code repository from the public repository:
```
git clone https://codeberg.org/diva.exchange/diva-dockerized.git
cd diva-dockerized
npm i
```

Now, either build your own local testnet or join the existing [DIVACHAIN testnet](https://testnet.diva.exchange). 

### Join the public DIVACHAIN Test Network

To join the DIVACHAIN test network, build a local docker compose file first. This is an automated process. Here is an example on how to join the DIVACHAIN test network via I2P (it will ask for the root password, since it has to access docker):
```
DIVA_TESTNET=1 bin/build.sh
```

After building the docker compose file, the containers can be **started**:
```
DIVA_TESTNET=1 bin/start.sh
```  

It is now possible to explore the local docker environment using docker commands, like `docker ps -a`.

To **stop** locally running DIVACHAIN Test Network containers, execute:
```
DIVA_TESTNET=1 bin/halt.sh
```

### Leave the DIVACHAIN Network

tbd.

### Local, I2P based DIVACHAIN Testnet

To create an I2P-based DIVACHAIN test network, build a local docker compose file first. This is an automated process. Here is an example:
```
BASE_IP=172.19.73. BASE_DOMAIN=testnet.local bin/build.sh
```

After building the docker compose file, the containers can be **started**:
```
BASE_DOMAIN=testnet.local bin/start.sh
```  

It is now possible to explore the local docker environment using docker commands, like `docker ps -a`.

To **stop** locally running DIVACHAIN Test Network containers, execute:
```
BASE_DOMAIN=testnet.local bin/halt.sh
```

### Purge local DIVACHAIN data

To purge all local data, execute:
```
BASE_DOMAIN=testnet.local bin/purge.sh
```

### Development: Use of Specific Docker Images
It is possible to specify docker images to build the .yml file used by docker compose.
Use the environment variables IMAGE_I2P, IMAGE_CHAIN, IMAGE_PROTOCOL and IMAGE_EXPLORER to pass specific image 
names to the build process. Here is an example:

```
DIVA_TESTNET=1 IMAGE_CHAIN=divax/divachain:develop bin/build.sh
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

### BASE_IP
String: valid local base IP, like 172.19.72.

Default: `172.19.72.`

### PORT
Integer: >1024, < 48000

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
String: trace, info, warn, error, critical

Default: `trace`

### PURGE
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
