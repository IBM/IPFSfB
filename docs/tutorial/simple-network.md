# Simple Network Tutorial

This is a tutorial for IPFSfB simple network. Simple network is based on InterPlanety File System with a privacy layer. This tutorial will show you a simple, private network.

## Quickstart

The [bootstrap.sh](../../samples/simple-network/scripts/bootstrap.sh) script will download binaries, tools and docker images for the simple (private) network. In the process, docker will download the images and tag them to latest. Tools will be installed in your network's bin directory. Optinally, you can specify the version tag for IPFSfB images. By default, version is 0.1.0.

``` bash
curl -sSL https://bit.ly/snetboot | bash -s <version>
```

After installed, you can enter to the network directory and just run:

``` bash
./pnet.sh up <network>
```

The network tag is one of [p2p](https://en.wikipedia.org/wiki/Peer-to-peer), [p2s](https://zh.wikipedia.org/wiki/P2S), and [p2sp](https://zh.wikipedia.org/wiki/P2SP).
This command will up and start a corresponding network.
During the network booting, swarmkeygen tool will generate a random, 32 bytes secret key in your network's `build` directory, and `docker cp` will copy it to each containers. At the same time, each network nodes will exchange their ipfs address with others. Finally, rebooting the network using the secret key (`swarm.key` file) will create a private network.

## Setting up private network manually

As above, download the network binaries, tools and docker images.

Enter to the network directory, and add the bin path to your PATH:

``` bash
export PATH=$PWD/bin:$PATH
```

Next, choose which network to start:

1. [P2P](#1-p2p)
2. [P2S](#2-p2s)
3. [P2SP](#3-p2sp)

### 1. P2P

Go to the p2p folder.

Bring up the network by running:

``` bash
docker-compose up -d
```

After brining up the network, enter to the container `peer0.example.com` by interative mode:

``` bash
docker exec -it peer0.example.com bash
```

Clean up the bootstrap nodes:

``` bash
ipfs bootstrap rm --all
```

Obtain the container's ipfs address:

``` bash
ipfs id -f='<addrs>'
```

Ignoring the localhost `127.0.0.1` address, copy the address that is not localhost, and exit the interative mode:

``` bash
exit
```

Now enter to container `peer1.example.com` by interative mode:

``` bash
docker exec -it peer1.example.com bash
```

As same as we do remove and obtain address for `peer0.example.com`, remove bootstrap nodes and obtain `peer1.example.com` address, then add `peer0.example.com` address to `peer1.example.com` bootstrap list, as we copied the `peer0.example.com` address above.

``` bash
ipfs bootstrap rm --all
ipfs id -f='<addrs>'
ipfs bootstrap add <your container peer0.example.com ipfs address>
```

As same as above, copy the container `peer1.example.com` ipfs address which is not starting with `127.0.0.1`, and exit the interative mode:

``` bash
exit
```

Enter to the container `peer0.example.com` again and add container `peer1.example.com` ipfs address, and finally exit the interative mode:

``` bash
docker exec -it peer0.example.com bash
ipfs bootstrap add <your container peer1.example.com ipfs address>
exit
```

Now generate a swarm key file, and copy it to each containers config path.

``` bash
swarmkeygen generate > swarm.key
docker cp swarm.key peer0.example.com:/var/ipfsfb
docker cp swarm.key peer1.example.com:/var/ipfsfb
```

Then restart the network by running:

``` bash
docker-compose restart
```

After restart, you can inspect each of the containers network status by docker logs:

``` bash
docker logs peer0.example.com
docker logs peer1.example.com
```

You should see the message - running a private network with a swarm key file, and the swarm key fingerprint.

Now we are in private network, with the swarm key file shared to container `peer0.example.com` and container `peer1.example.com`.

### 2. P2S

P2S scenario is enabled global network address for the server's profile, which will export your current host machine address to the containers address. You can refer to the network settings in the p2s [env](../../samples/simple-network/p2s/.env) file.

Go to the p2s folder.

Bring up the network by running:

``` bash
docker-compose up -d
```

After brining up the network, enter to the container `server.example.com` by interative mode:

``` bash
docker exec -it server.example.com bash
```

Clean up the bootstrap nodes:

``` bash
ipfs bootstrap rm --all
```

Obtain the container's ipfs address:

``` bash
ipfs id -f='<addrs>'
```

Ignoring the localhost `127.0.0.1` address, copy the address that is not localhost, and exit the interative mode:

``` bash
exit
```

Now enter to container `peer.example.com` by interative mode:

``` bash
docker exec -it peer.example.com bash
```

As same as we do remove and obtain address for `server.example.com`, remove bootstrap nodes and obtain `peer.example.com` address, then add `server.example.com` address to `peer.example.com` bootstrap list, as we copied the `server.example.com` address above.

``` bash
ipfs bootstrap rm --all
ipfs id -f='<addrs>'
ipfs bootstrap add <your container server.example.com ipfs address>
```

As same as above, copy the container `peer.example.com` ipfs address which is not starting with `127.0.0.1`, and exit the interative mode:

``` bash
exit
```

Enter to the container `server.example.com` again and add container `peer.example.com` ipfs address, and finally exit the interative mode:

``` bash
docker exec -it server.example.com bash
ipfs bootstrap add <your container peer.example.com ipfs address>
exit
```

Now generate a swarm key file, and copy it to each containers config path.

``` bash
swarmkeygen generate > swarm.key
docker cp swarm.key server.example.com:/var/ipfsfb
docker cp swarm.key peer.example.com:/var/ipfsfb
```

Then restart the network by running:

``` bash
docker-compose restart
```

After restart, you can inspect each of the containers network status by docker logs:

``` bash
docker logs server.example.com
docker logs peer.example.com
```

You should see the message - running a private network with a swarm key file, and the swarm key fingerprint.

Now we are in private network, with the swarm key file shared to container `server.example.com` and container `peer.example.com`.

Additionaly, the `server.example.com` api and gateway can be accessed from `peer.example.com` or any others in the network, as we enabled global api and gateway settings for the server in [config.sh](../../samples/simple-network/config.sh).

### 3. P2SP

P2SP scenario is enabled global network address for the server's profile, which will export your current host machine address to the containers address. You can refer to the network settings in the p2sp [env](../../samples/simple-network/p2sp/.env) file.

Go to the p2sp folder.

Bring up the network by running:

``` bash
docker-compose up -d
```

After brining up the network, enter to the container `server.example.com` by interative mode:

``` bash
docker exec -it server.example.com bash
```

Clean up the bootstrap nodes:

``` bash
ipfs bootstrap rm --all
```

Obtain the container's ipfs address:

``` bash
ipfs id -f='<addrs>'
```

Ignoring the localhost `127.0.0.1` address, copy the address that is not localhost, and exit the interative mode:

``` bash
exit
```

Now enter to container `peer0.example.com` by interative mode:

``` bash
docker exec -it peer0.example.com bash
```

As same as we do remove and obtain address for `server.example.com`, remove bootstrap nodes and obtain `peer0.example.com` address, then add `server.example.com` address to `peer0.example.com` bootstrap list, as we copied the `server.example.com` address above.

``` bash
ipfs bootstrap rm --all
ipfs id -f='<addrs>'
ipfs bootstrap add <your container server.example.com ipfs address>
```

As same as above, copy the container `peer0.example.com` ipfs address which is not starting with `127.0.0.1`, and exit the interative mode:

``` bash
exit
```

Now enter to container `peer1.example.com` by interative mode:

``` bash
docker exec -it peer1.example.com bash
```

As we do the same above, remove bootstrap nodes and obtain `peer1.example.com` address, then add `server.example.com` address and `peer0.example.com` address to `peer1.example.com` bootstrap list, as we copied the `server.example.com` and `peer0.example.com` addresses above.

``` bash
ipfs bootstrap rm --all
ipfs id -f='<addrs>'
ipfs bootstrap add <your container server.example.com ipfs address>
ipfs bootstrap add <your container peer0.example.com ipfs address>
```

As same as above, copy the container `peer1.example.com` ipfs address which is not starting with `127.0.0.1`, and exit the interative mode:

``` bash
exit
```

Now let's back to the container `peer0.example.com`, and add `peer1.example.com` address that we have just obtained to `peer0.example.com` bootstrap list, and finally exit the interative mode:

``` bash
docker exec -it peer0.example.com bash
ipfs bootstrap add <your container peer1.example.com ipfs address>
exit
```

Back to the container `server.example.com` and add `peer0.example.com` ipfs address and `peer1.example.com` ipfs address, and finally exit the interative mode:

``` bash
docker exec -it server.example.com bash
ipfs bootstrap add <your container peer0.example.com ipfs address>
ipfs bootstrap add <your container peer1.example.com ipfs address>
exit
```

Now generate a swarm key file, and copy it to each containers config path.

``` bash
swarmkeygen generate > swarm.key
docker cp swarm.key server.example.com:/var/ipfsfb
docker cp swarm.key peer0.example.com:/var/ipfsfb
docker cp swarm.key peer1.example.com:/var/ipfsfb
```

Then restart the network by running:

``` bash
docker-compose restart
```

After restart, you can inspect each of the containers network status by docker logs:

``` bash
docker logs server.example.com
docker logs peer0.example.com
docker logs peer1.example.com
```

You should see the message - running a private network with a swarm key file, and the swarm key fingerprint.

Now we are in private network, with the swarm key file shared to container `server.example.com`, container `peer0.example.com` and container `peer1.example.com`.

Additionaly, the `server.example.com` api and gateway can be accessed from `peer0.example.com` or `peer1.example.com` or any others in the network, as we enabled global api and gateway settings for the server in [config.sh](../../samples/simple-network/config.sh).