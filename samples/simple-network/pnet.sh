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
export IPFS_PATH=${PWD}/../../.build

# Print the help message.
function printHelper () {
    echo "Usage: "
    echo "  pnet.sh <command> <subcommand>"
    echo "      <command> - one of 'start', 'stop' or 'restart'."
    echo "          - 'start' - start and up the network with docker-compose up."
    echo "          - 'stop' - stop and clear the network with docker-compose down."
    echo "          - 'restart' - restart the network."
    echo "      <subcommand> - networks type, <subcommand=p2p|p2s|p2sp>."
    echo "Flags: "
    echo "  -n <network> - print all available network."
    echo "  -i <imagetag> - the tag for the private network launch (defaults to latest)."
    echo "  -f <composefile> - docker-compose file to be selected (defaults to docker-compose.yml)."
}

# Print all network.
function printNetwork () {
    echo "Usage: "
    echo "  pnet.sh <command> <subcommand>"
    echo "      <command> - <command=start|stop|restart> corresponding network based on user choice."
    echo "      <subcommand> - one of 'p2p', 'p2s', or 'p2sp'."
    echo "          - 'p2p' - a peer-to-peer based, private network."
    echo "          - 'p2s' - a peer-to-server based, private network."
    echo "          - 'p2sp' - a peer to server and to peer based, private network."
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
    set -x
    swarmkeygen generate > $IPFS_PATH/swarm.key
    res=$?
    set +x
    if [ $res -ne 0 ]; then
        echo "Failed to generate swarm.key file, exit."
        exit 1
    fi
}

# Create containers environment
function createContainers () {
    echo "---- Creat containers for running IPFS. ----"
    for PEER in peer0.example.com peer1.example.com; do
        IMAGE_TAG=$IMAGETAG docker-compose -f $COMPOSE_FILE_P2P up --no-start $PEER
    done
}

# Copy swarm key file into container
function copySwarmKey () {
    echo "---- Copy swarm key file into the container file system. ----"
    for PEER in peer0.example.com peer1.example.com; do
        set -x
        docker cp -a $IPFS_PATH/swarm.key $PEER:/var/ipfsfb
        set +x
    done
}

# Start containers
function startContainers () {
    echo "---- Start containers using secret swarm key. ----"
    for PEER in peer0.example.com peer1.example.com; do
        IMAGE_TAG=$IMAGETAG docker-compose -f $COMPOSE_FILE_P2P start $PEER
    done
    echo "---- Sleeping 10s to allow network complete booting. ----"
    sleep 10
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

# Start and up a peer to peer based network
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

# Stop and clear peer to peer based network
function stopP2p () {
    docker-compose -f $COMPOSE_FILE_P2P down --volumes --remove-orphans
}

# Start a peer to server based network
#function startP2s () {

#}

# Start a peer to server and to peer based network
#function startP2sp () {

#}

# Use default docker-compose file
COMPOSE_FILE=docker-compose.yml
# Set networks docker-compose file
COMPOSE_FILE_P2P=./p2p/${COMPOSE_FILE}
COMPOSE_FILE_P2S=./p2s/${COMPOSE_FILE}
COMPOSE_FILE_P2SP=./p2sp/${COMPOSE_FILE}
# Set image tag
IMAGETAG=latest

# Options for running command
while getopts "h?n?i:f:" opt; do
    case "$opt" in
        h | \?)
            printHelper
            exit 0
            ;;
        n)
            printNetwork
            exit 0
            ;;
        i)
            IMAGETAG=$OPTARG
            ;;
        f)
            COMPOSE_FILE=$OPTARG
            ;;
    esac
done

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
elif [ "${COMMAND}" == "stop" ]; then
    if [ "${SUBCOMMAND}" == "p2p" ]; then
        stopP2p
    elif [ "${SUBCOMMAND}" == "p2s" ]; then
        stopP2s
    elif [ "${SUBCOMMAND}" == "p2sp" ]; then
        stopP2sp
    else
        printNetwork
        exit 1
    fi
else
    printHelper
    exit 1
fi