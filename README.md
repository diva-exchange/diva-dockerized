# DIVA.EXCHANGE "Dockerized"

This project has the following purpose: even if DIVA.EXCHANGE consists of several independent modules, it still should be easy to have the complete environment available.

Online Demo and Test sites:
* https://testnet.diva.exchange - The public DIVA.EXCHANGE testnet. Everybody can join. 

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

To start the local testnet (3 nodes) execute:
```
sudo docker-compose -f docker-compose/local-testnet.yml pull && sudo docker-compose -f docker-compose/local-testnet.yml up -d
```

To stop the local testnet execute:
```
sudo docker-compose -f docker-compose/local-testnet.yml down --volumes
```

Open your browser and take a look at your local testnet using the Iroha Blockchain Explorer: http://localhost:3920 . Remark: it takes a few seconds to start the docker container which contains the explorer.

### Beta & Private: I2P based Testnet

To start the I2P-based local testnet (3 nodes) execute:
```
sudo docker-compose -f docker-compose/i2p-testnet.yml up -d
```

To stop the I2P-based testnet execute:
```
sudo docker-compose -f docker-compose/i2p-testnet.yml down --volumes
```

Starting up the I2P testnet might take while - up to 5 minutes.

Open your browser and take a look at your local testnet using the Iroha Blockchain Explorer: http://localhost:3920

## Contact the Developers

On [DIVA.EXCHANGE](https://www.diva.exchange) you'll find various options to get in touch with the team. 

Talk to us via Telegram [https://t.me/diva_exchange_chat_de]() (English or German).

## Donations

Your donation goes entirely to the project. Your donation makes the development of DIVA.EXCHANGE faster.

XMR: 42QLvHvkc9bahHadQfEzuJJx4ZHnGhQzBXa8C9H3c472diEvVRzevwpN7VAUpCPePCiDhehH4BAWh8kYicoSxpusMmhfwgx

BTC: 3Ebuzhsbs6DrUQuwvMu722LhD8cNfhG1gs

Awesome, thank you!
