# DIVA.EXCHANGE "Dockerized"

This project has the following purpose: even if DIVA.EXCHANGE consists of several independent modules, it still should be easy to have the complete environment available.

Online Demo and Test sites:
* https://testnet.diva.exchange - The public DIVA.EXCHANGE testnet. Everybody can join.

It's licenced under [AGPLv3](LICENSE).


## Get Started

There are two different flavours of testnets available: a simple local one and an I2P based one.

**Stable:** the local testnet runs on your local network. It's fast and available on your local network only. Use it for application development.

**Beta & Private:** the I2P based testnet routes all traffic between the Iroha nodes through the private network I2P. The Iroha nodes itself remain private. The I2P network might have quite some latency and hence the synchronisation between the Iroha nodes might be slow.

### Docker Compose & Clone the Code

**IMPORTANT**: To start a local Iroha testnet, make sure you have [Docker Compose](https://docs.docker.com/compose/install/) installed. Check your Docker Compose installation by executing `docker-compose --version` in a terminal.

Clone the code repository from the public repository:
```
git clone -b master https://codeberg.org/diva.exchange/diva-dockerized.git
cd diva-dockerized
```

Now one of the following Testnets can be started.

### Stable: Local Testnet

To start the local testnet (7 nodes) execute:
```
sudo docker-compose -f docker-compose/local-testnet.yml pull && sudo docker-compose -f docker-compose/local-testnet.yml up -d
```

To stop the local testnet execute:
```
sudo docker-compose -f docker-compose/local-testnet.yml down --volumes
```

Open your browser and take a look at your local testnet using the Iroha Blockchain Explorer: http://localhost:3920 . Remark: it takes a few seconds to start the docker container which contains the explorer.

### Beta & Private: I2P based Testnet

To start the I2P-based testnet (7 nodes) execute:
```
sudo bin/start-testnet.sh
```

To stop the I2P-based testnet execute:
```
sudo bin/stop-testnet.sh
```

Starting up the I2P testnet might take while - up to 5 minutes.

Open your browser and take a look at your local testnet using the Iroha Blockchain Explorer: http://localhost:3920

## Join the Testnet of DIVA.EXCHANGE

### *nix Environment

#### Joining the Network
The testnet is publicly available. The explorer is found here: https://testnet.diva.exchange

We assume you are using some debian flavour (like ubuntu). First, make sure you have docker available:
```
sudo apt-get install docker.io
```

Clone diva-dockerized (develop branch):
```
git clone -b develop https://codeberg.org/diva.exchange/diva-dockerized.git
cd diva-dockerized
```

The script below (join-testnet.sh) will perform the following actions as root:
* Create an I2P node, as a docker container
* Create a DIVA API node, as a docker container
* Create an Iroha node, as a docker container
* Create an Iroha Postgres node, as a docker container

Therefore four additional docker container will be running on your host, something like (`docker ps`):
```
CONTAINER ID        IMAGE                             NAMES
80a95b4440dc        divax/diva-api:latest             nx1.api.testnet.diva.i2p
44528359ab1e        divax/iroha:1.2.0-prop-strategy   nx1.testnet.diva.i2p
f9e4adb88ee9        postgres:10-alpine                nx1.db.testnet.diva.i2p
5ecdde77dbc3        divax/i2p:latest                  nx1.i2p.testnet.diva.i2p
```

Additionally there will be a network created (so the container can talk to each other), like (`docker network ls`):
```
NETWORK ID          NAME                       DRIVER              SCOPE
f01cb4d30a08        nx1.net.testnet.diva.i2p   bridge              local
```

And some volumes will be available too, like (`docker volume ls`):
```
DRIVER              VOLUME NAME
local               nx1.api.testnet.diva.i2p
local               nx1.db.testnet.diva.i2p
local               nx1.i2p.testnet.diva.i2p
local               nx1.testnet.diva.i2p
```

Now, join the network by launching the following script (as root, since it accesses docker):
```
sudo bin/join-testnet.sh
```

Your iroha node will now start to integrate into the testnet. This will take a while (like 30 minutes or more), since the whole blockchain needs to be downloaded (ie. synchronized). BTW: this could be solved much more efficiently and it's an open task. If you'd like to help us out, drop a message in the [Telegram chat](https://t.me/diva_exchange_chat_de)!

The integration will also register as a new peer on the blockchain. Additionally a new account gets created. You can easily follow this process by looking at the verbose logs, like:

```
sudo docker logs -t -f nx1.api.testnet.diva.i2p
```

Please note: the peer is on I2P - this is a slow P2P network. So just be patient. Questions: ask in the DIVA Telegram chat!

IMPORTANT: `join-testnet.sh` might be executed multiple times. Every time a new node (4 new docker container) will be created and the whole process will be initiated. Sooner or later your host will run out of resources.

#### Leaving the Network
To leave the testnet, execute the script:
```
sudo bin/leave-testnet.sh
```

It will shut down **all** your local nodes (nx1..nxN) and remove all local docker containers related to the testnet. The volumes of Iroha and I2P will persist. Therefore re-joining the testnet will be quicker. To completely remove all data, remove the volumes manually (like `sudo docker volume rm nx1.testnet.diva.i2p`).


### Windows Environment
tbd.

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
