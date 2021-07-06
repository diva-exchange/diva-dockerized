# DIVA.EXCHANGE "Dockerized"

This project has the following purpose: even if DIVA.EXCHANGE consists of several independent modules, it still should be easy to have the complete environment available.

Online Demo and Test sites:
* https://testnet.diva.exchange - The public DIVA.EXCHANGE testnet. Everybody can join.

It's licenced under [AGPLv3](LICENSE).


## Get Started

There are two different flavours of testnets available: a simple local one and an I2P-based one.

**Local:** the local testnet runs on your local network. It's fast and available on your local network only. Use it for application development.

**Private (I2P):** the I2P based testnet routes all traffic between the DIVACHAIN nodes through the private network I2P. The DIVACHAIN nodes itself remain private. The I2P network might have quite some latency.

### Docker Compose & Clone the Code

**IMPORTANT**: To start a local DIVA testnet, make sure you have [Docker Compose](https://docs.docker.com/compose/install/) installed. Check your Docker Compose installation by executing `docker-compose --version` in a terminal.

Clone the code repository from the public repository:
```
git clone -b divachain https://codeberg.org/diva.exchange/diva-dockerized.git
cd diva-dockerized
```

Now one of the following Testnets can be started.

### Join the DIVACHAIN Test Network

To join the DIVACHAIN testnet execute (it will ask for the root password, since it has to access docker):
```
HAS_I2P=1 BASE_DOMAIN=testnet.diva.i2p bin/join.sh
```

### Leave the DIVACHAIN Test Network

To leave the DIVACHAIN testnet execute (it will ask for the root password, since it has to access docker):
```
BASE_DOMAIN=testnet.diva.i2p bin/leave.sh
```

### Join the DIVACHAIN Network

To join the DIVACHAIN network execute (it will ask for the root password, since it has to access docker):
```
HAS_I2P=1 BASE_DOMAIN=diva.i2p bin/join.sh
```

### Leave the DIVACHAIN Network

To leave the DIVACHAIN network execute (it will ask for the root password, since it has to access docker):
```
BASE_DOMAIN=diva.i2p bin/leave.sh
```

### Local DIVACHAIN Testnet

To start the local testnet (7 nodes) execute (it will ask for the root password, since it has to access docker):
```
bin/start-testnet.sh
```

To stop the local testnet execute:
```
bin/stop-testnet.sh
```

Open your browser and take a look at your local testnet using the Blockchain Explorer: http://localhost:3920 . Remark: it takes a few seconds to start the docker container which contains the explorer.

### I2P based DIVACHAIN Testnet

To start the I2P-based testnet (7 nodes) execute:
```
HAS_I2P=1 bin/start-testnet.sh
```

To stop the I2P-based testnet execute:
```
bin/stop-testnet.sh
```

Starting up the I2P testnet might take while - up to 5 minutes.

Open your browser and take a look at your local testnet using the Blockchain Explorer: http://localhost:3920

### Purge your local DIVACHAIN Network

To purge all data of your testnet (7 nodes - local or I2P-based) execute:
```
bin/purge-testnet.sh
```

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
