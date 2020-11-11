# DIVA.EXCHANGE "Dockerized"

This project has the following purpose: even if DIVA.EXCHANGE consists of several independent modules, it still should be easy to have the complete environment available.

Online Demo and Test sites:
* https://testnet.diva.exchange - The public DIVA.EXCHANGE testnet. Everybody can join. 

## Get Started

There are three different flavours of testnets available: a simple local one, an I2P based one and a peer-to-peer (P2P) based one.

**Stable:** the local testnet runs on your local network. It's fast and available on your local network only. Use it for application development.

**Stable & Private:** the I2P based testnet routes all traffic between the Iroha nodes through the private network I2P. The Iroha nodes itself remain private. The I2P network might have quite some latency and hence the synchronisation between the Iroha nodes might be slow.

**Experimental:** the peer-to-peer (P2P) based testnet routes all traffic between the Iroha nodes through the clearnet. Initially, the Iroha nodes are connected with each other with the help of a signal/STUN service. A signal/STUN service enables peer-to-peer connections behind firewalls. This signal/STUN implementation is used to establish the connections between the Iroha nodes: https://codeberg.org/diva.exchange/signal 

### Clone the Code

Clone the code repository from the public repository:
```
git clone -b master https://codeberg.org/diva.exchange/diva-dockerized.git
cd diva-dockerized
```

Now one of the following Testnets can be started.

### Stable: Local Testnet

To start a preconfigured local testnet, make sure you have "Docker Compose" installed (https://docs.docker.com/compose/install/). Check your Docker Compose installation by executing `docker-compose --version` in a terminal.

To start the local testnet (3 nodes) execute:
```
sudo docker-compose -f docker-compose/local-testnet.yml up -d
```

To stop the local testnet execute:
```
sudo docker-compose -f docker-compose/local-testnet.yml down --volumes
```

Open your browser and take a look at your local testnet using the Iroha Blockchain Explorer: http://127.20.101.100:3920

### Stable & Private: I2P based Testnet

Clone the code repository from the public repository:
```
git clone -b master https://codeberg.org/diva.exchange/diva-dockerized.git
cd diva-dockerized
```

To start a preconfigured local testnet, make sure you have "Docker Compose" installed (https://docs.docker.com/compose/install/). Check your Docker Compose installation by executing `docker-compose --version` in a terminal.

To start the I2P-based local testnet (3 nodes) execute:
```
sudo docker-compose -f docker-compose/i2p-testnet.yml up -d
```

To stop the I2P-based testnet execute:
```
sudo docker-compose -f docker-compose/i2p-testnet.yml down --volumes
```

Starting up the I2P testnet might take while - up to 5 minutes.

Open your browser and take a look at your local testnet using the Iroha Blockchain Explorer: http://127.20.101.100:3920

### Experimental: Peer-to-peer based Testnet

Clone the code repository from the public repository:
```
git clone -b master https://codeberg.org/diva.exchange/diva-dockerized.git
cd diva-dockerized
```

To join or start a preconfigured local testnet, make sure you have "Docker Compose" installed (https://docs.docker.com/compose/install/). Check your Docker Compose installation by executing `docker-compose --version` in a terminal.

To join an existing network, like the "testnet" of diva.exchange (see https://testnet.diva.exchange):
```
sudo docker-compose -f docker-compose/p2p-join-testnet.yml up -d
```

To disconnect from the testnet:
```
sudo docker-compose -f docker-compose/p2p-join-testnet.yml down --volumes
```

To start the peer-to-peer-based local testnet (3 nodes) execute:
```
sudo docker-compose -f docker-compose/p2p-testnet.yml up -d
```

To stop the peer-to-peer-based testnet execute:
```
sudo docker-compose -f docker-compose/p2p-testnet.yml down --volumes
```

## Contact the Developers

On [DIVA.EXCHANGE](https://www.diva.exchange) you'll find various options to get in touch with the team. 

Talk to us via Telegram [https://t.me/diva_exchange_chat_de]() (English or German).

## Donations

Your donation goes entirely to the project. Your donation makes the development of DIVA.EXCHANGE faster.

XMR: 42QLvHvkc9bahHadQfEzuJJx4ZHnGhQzBXa8C9H3c472diEvVRzevwpN7VAUpCPePCiDhehH4BAWh8kYicoSxpusMmhfwgx

BTC: 3Ebuzhsbs6DrUQuwvMu722LhD8cNfhG1gs

Awesome, thank you!
