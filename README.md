# DIVA.EXCHANGE "Dockerized"

This project has the following purpose: even if DIVA.EXCHANGE consists of several independent modules, it still should be easy to have the complete environment available.

Online Demo and Test sites:
* https://testnet.diva.exchange - The public DIVA.EXCHANGE testnet. Everybody can join. 

## Get Started

There are two different flavours of testnets available: an I2P based one and a peer-to-peer based one.

The I2P based testnet routes all traffic between the Iroha nodes through the private network I2P. The Iroha nodes itself remain private. The I2P network might have quite some latency and hence the synchronisation between the Iroha nodes might be slow.

The peer-to-peer based testnet routes all traffic between the Iroha nodes through the clearnet. Initially, the Iroha nodes are connected with each other with the help of a signal/STUN service. A signal/STUN service enables peer-to-peer connections behind firewalls. This signal/STUN implementation is used to establish the connections between the Iroha nodes: https://codeberg.org/diva.exchange/signal 

### I2P based Testnet

To start the I2P-based testnet (3 nodes) execute:

```
./bin/start-i2p-testnet.sh
```

To stop the I2P-based testnet execute:

```
./bin/halt-i2p-testnet.sh
```


### Peer-to-peer based local Testnet

To start the peer-to-peer-based local testnet (3 nodes) execute:

```
./bin/start-p2p-testnet.sh
```

To stop the peer-to-peer-based testnet execute:

```
./bin/halt-p2p-testnet.sh
```

### Join testnet.diva.exchange

To join the existing https://testnet.diva.exchange network:

```
JOIN_EXISTING=1 \
BLOCKCHAIN_NETWORK=testnet \
./bin/start-p2p-testnet.sh
```

To disconnect from the network:

```
./bin/halt-p2p-testnet.sh
```

## Contact the Developers

On [DIVA.EXCHANGE](https://www.diva.exchange) you'll find various options to get in touch with the team. 

Talk to us via Telegram [https://t.me/diva_exchange_chat_de]() (English or German).

## Donations

Your donation goes entirely to the project. Your donation makes the development of DIVA.EXCHANGE faster.

XMR: 42QLvHvkc9bahHadQfEzuJJx4ZHnGhQzBXa8C9H3c472diEvVRzevwpN7VAUpCPePCiDhehH4BAWh8kYicoSxpusMmhfwgx

BTC: 3Ebuzhsbs6DrUQuwvMu722LhD8cNfhG1gs

Awesome, thank you!
