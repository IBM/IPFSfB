#!/bin/bash
# Copyright 2019 IBM Corp.

# Licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at 

#   http://www.apache.org/licenses/LICENSE-2.0 

# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and 
# limitations under the License.

# Setting environment variable
export PATH=${PWD}:$PATH
export IPFS_PATH=${PWD}/../../build

# Print the help message.
function printHelper () {
    echo "Usage: "
    echo "  pnet.sh <command> "
    echo "Flags: "
    echo "  -p <profile> - the IPFS profile for initialization."
    echo "  --routing <routing> - overrides the routing option (defaults to default)."
}

# Print all network.
function printNetwork () {
    echo "Usage: "
    echo "  pnet.sh start <subcommand> - start corresponding network based on user choice."
    echo "      <subcommand> - one of 'p2p', 'p2s', or 'p2sp'."
    echo "          - 'p2p' - start a peer-to-peer based, private network."
    echo "          - 'p2s' - start a peer-to-server based, private network."
    echo "          - 'p2sp' - start a peer to server and to peer based, private network."
    echo
    echo "Typically, one can bring up the network through subcommand e.g.:"
    echo
    echo "      ./pnet.sh start p2p"
    echo
}

# Generate swarm key
function generateKey () {
    which swarmkeygen
    if [ "$?" -ne 0 ]; then
        echo "swarmkeygen tool not found, exit."
        exit 1
    fi
    echo "---- Generate swarm.key file using swarmkeygen tool. ----"
    swarmkeygen generate > $IPFS_PATH/swarm.key
    res=$?
    set -x
    if [ $res -ne 0 ]; then
        echo "Failed to generate swarm.key file, exit."
        exit 1
    fi
    set +x
}

# Create containers environment
function createContainers () {
    echo "---- Creat containers for running IPFS. ----"
    for PEER in peer0.example.com peer1.example.com; do
        docker-compose up --no-start $PEER
    done
}

# Copy swarm key file into container
function copySwarmKey () {
    echo "---- Copy swarm key file into the container file system. ----"
    for PEER in peer0.example.com peer1.example.com; do
        docker cp -a $IPFS_PATH/swarm.key $PEER:/var/ipfsfb
    done
}

# Start containers
function startContainers () {
    echo "---- Start containers using secret swarm key. ----"
    for PEER in peer0.example.com peer1.example.com; do
        docker-compose start $PEER
    done
}

# Set and switch to private network
function privateNetUp () {
    echo "---- Configure the private network. ----"
    for PEER in peer0.example.com peer1.example.com; do
        docker exec $PEER ipfs bootstrap rm --all
    done
    PEER_ADDR=$(docker exec peer0.example.com ipfs id -f='<addrs>' | tail -n 1)
    docker exec peer1.example.com ipfs bootstrap add $PEER_ADDR
    PEER_ADDR=$(docker exec peer1.example.com ipfs id -f='<addrs>' | tail -n 1)
    docker exec peer0.example.com ipfs bootstrap add $PEER_ADDR
}

# Start a peer to peer based network
function startP2p () {
    if [ -d "$IPFS_PATH" ]; then
        generateKey
        createContainers
        copySwarmKey
        startContainers
        privateNetUp
    fi
    IMAGE_TAG=$IMAGETAG docker-compose -f $COMPOSE_FILE_P2P up -d 2>&1
    if [ $? -ne 0 ]; then
        echo "ERROR!!! could not start p2p network, exit."
        exit 1
    fi
}

# Start a peer to server based network
function startP2s () {

}

# Start a peer to server and to peer based network
function startP2sp () {

}

# Use default docker-compose file
COMPOSE_FILE=docker-compose.yml
# Set networks docker-compose file
COMPOSE_FILE_P2P=./p2p/${COMPOSE_FILE}
COMPOSE_FILE_P2S=./p2s/${COMPOSE_FILE}
COMPOSE_FILE_P2SP=./p2sp/${COMPOSE_FILE}
# Set image tag (defaults to latest)
IMAGETAG=latest

# The arg of the command
COMMAND=$1;SUBCOMMAND=$2;shift

# Command interface for execution
if [ "${COMMAND}" == "start" ]; then
    if [ "${SUBCOMMAND}" == "p2p" ]; then
        startP2p
    elif [ "${SUBCOMMAND}" == "p2s" ]; then
        startP2s
    elif [ "${SUBCOMMAND}" == "p2sp" ]; then
        startP2sp
    else
        printNetwork
        exit 1
    fi
else
    printHelper
    exit 1
fi