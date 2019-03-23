# Simple Network Tutorial

## Quickstart

The [bootstrap.sh](https://github.com/IBM/IPFSfB/blob/master/samples/simple-network/scripts/bootstrap.sh) script will download binaries, tools and docker images for the private network. In the process, docker will download the images and tag them to latest. Tools will be installed in your network's bin directory. Optinally, you can specify the version tag for IPFSfB images. By default, version is 0.1.0.

``` bash
curl -sSL https://bit.ly/snetboot | bash -s <version>
```

After installed, you can locate in the network directory and just run:

``` bash
./pnet.sh up <network>
```

The network tag is one of [p2p](https://en.wikipedia.org/wiki/Peer-to-peer), [p2s](https://zh.wikipedia.org/wiki/P2S), and [p2sp](https://zh.wikipedia.org/wiki/P2SP).
This command will up and start the corresponding network.
During the network booting, swarmkeygen tool will generate a random, 32 bytes secret key in your network's `build` directory, and `docker cp` will copy it to each containers. At the same time, each network nodes will exchange their ipfs address with others. Finally, rebooting the network using the secret key (`swarm.key` file) will create a private network.

## Setting up the private network manually

As above, download the network binaries, tools and docker images.

Enter to the network folder, and add the bin path to your PATH:

``` bash
export PATH=$PWD/bin:$PATH
```

Choose which network to start, for example, p2p. Then go to the p2p folder.

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