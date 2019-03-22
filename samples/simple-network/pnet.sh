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

# A script for running the private network, each of peer-to-peer, peer-to-server, and peer to peer and to server

# Set environment variable
export PATH=${PWD}/bin:${PWD}:$PATH
export BUILD_PATH=${PWD}/build

# Print the help message.
function printHelper() {
	echo "Usage: "
	echo "  pnet.sh <command> <subcommand>"
	echo "      <command> - one of 'up', 'down', 'restart' or 'generate'."
	echo "          - 'up' - start and up the network with docker-compose up."
	echo "          - 'down' - stop and clear the network with docker-compose down."
	echo "          - 'restart' - restart the network."
	echo "          - 'generate' - generate swarm key file."
	echo "      <subcommand> - network type, <subcommand=p2p|p2s|p2sp>."
	echo "Flags: "
	echo "  -n <network> - print all available network."
	echo "  -i <imagetag> - the tag for the private network launch (defaults to latest)."
	echo "  -f <docker-compose-file> - docker-compose file to be selected (defaults to docker-compose.yml)."
}

# Print all network.
function printNetwork() {
	echo "Usage: "
	echo "  pnet.sh <command> <subcommand>"
	echo "      <command> - <command=up|down|restart> corresponding network based on user choice."
	echo "      <subcommand> - one of 'p2p', 'p2s', or 'p2sp'."
	echo "          - 'p2p' - a peer-to-peer based, private network."
	echo "          - 'p2s' - a peer-to-server based, private network."
	echo "          - 'p2sp' - a peer to server and to peer based, private network."
	echo
	echo "Typically, one can bring up the network through subcommand e.g.:"
	echo
	echo "      ./pnet.sh up p2p"
	echo
}

# Generate swarm key
function generateKey() {
	which swarmkeygen
	if [ "$?" -ne 0 ]; then
		echo "swarmkeygen tool not found, exit."
		exit 1
	fi
	echo "---- Generate swarm.key file using swarmkeygen tool. ----"
	set -x
	swarmkeygen generate > $BUILD_PATH/swarm.key
	res=$?
	set +x
	if [ $res -ne 0 ]; then
		echo "Failed to generate swarm.key file, exit."
		exit 1
	fi
}

# Docker-compose interface for create containers.
function composeCreate() {
	IMAGE_TAG=$IMAGETAG docker-compose -f $1 up --no-start $CONTAINER
}

# Create containers environment
function createContainers() {
	echo "---- Creat containers for running IPFS. ----"
	if [ "$SUBCOMMAND" == "p2p" ]; then
		for CONTAINER in peer0.example.com peer1.example.com; do
			composeCreate $COMPOSE_FILE_P2P
		done
	elif [ "$SUBCOMMAND" == "p2s" ]; then
		for CONTAINER in peer.example.com server.example.com; do
			composeCreate $COMPOSE_FILE_P2S
		done
	else
		for CONTAINER in peer0.example.com peer1.example.com server.example.com; do
			composeCreate $COMPOSE_FILE_P2SP
		done
	fi
}

# Docker cp interface for copy swarm key
function dockerCp() {
	set -x
	docker cp -a $BUILD_PATH/swarm.key $CONTAINER:/var/ipfsfb
	set +x
}

# Copy swarm key file into container
function copySwarmKey() {
	echo "---- Copy swarm key file into the container file system. ----"
	if [ "$SUBCOMMAND" == "p2p" ]; then
		for CONTAINER in peer0.example.com peer1.example.com; do
			dockerCp
		done
	elif [ "$SUBCOMMAND" == "p2s" ]; then
		for CONTAINER in peer.example.com server.example.com; do
			dockerCp
		done
	else
		for CONTAINER in peer0.example.com peer1.example.com server.example.com; do
			dockerCp
		done
	fi
}

# Docker-compose interface for start containers
function composeStart() {
	IMAGE_TAG=$IMAGETAG docker-compose -f $1 start $CONTAINER
}

# Start containers
function startContainers() {
	echo "---- Start containers using secret swarm key. ----"
	if [ "$SUBCOMMAND" == "p2p" ]; then
		for CONTAINER in peer0.example.com peer1.example.com; do
			composeStart $COMPOSE_FILE_P2P
		done
	elif [ "$SUBCOMMAND" == "p2s" ]; then
		for CONTAINER in peer.example.com server.example.com; do
			composeStart $COMPOSE_FILE_P2S
		done
	else
		for CONTAINER in peer0.example.com peer1.example.com server.example.com; do
			composeStart $COMPOSE_FILE_P2SP
		done
	fi
	echo "---- Sleeping 12s to allow network complete booting. ----"
	sleep 12
}

# Remove all default bootstrap nodes
function removeBootstrap() {
	docker exec $CONTAINER ipfs bootstrap rm --all
}

# Get containers ipfs address
function getAddress() {
	CONTAINER_ADDR=$(docker exec $CONTAINER ipfs id -f='<addrs>' | tail -n 1)
}

# Add bootstarp nodes for the network
function addBootstrap() {
	if [ "$CONTAINER" != "$CNAME" ]; then
		docker exec $CNAME ipfs bootstrap add $CONTAINER_ADDR
	fi
}

# Set and switch to private network, CONTAINER and CNAME are container alias
function switchPrivateNet() {
	echo "---- Configure the private network. ----"
	if [ "$SUBCOMMAND" == "p2p" ]; then
		for CONTAINER in peer0.example.com peer1.example.com; do
			removeBootstrap
		done
		for CONTAINER in peer0.example.com peer1.example.com; do
			getAddress
			for CNAME in peer1.example.com peer0.example.com; do
				addBootstrap
			done
		done
	elif [ "$SUBCOMMAND" == "p2s" ]; then
		for CONTAINER in peer.example.com server.example.com; do
			removeBootstrap
		done
		for CONTAINER in peer.example.com server.example.com; do
			getAddress
			for CNAME in server.example.com peer.example.com; do
				addBootstrap
			done
		done
	else
		for CONTAINER in peer0.example.com peer1.example.com server.example.com; do
			removeBootstrap
		done
		for CONTAINER in peer0.example.com peer1.example.com server.example.com; do
			getAddress
			for CNAME in peer1.example.com server.example.com peer0.example.com; do
				addBootstrap
			done
		done
	fi
}

# Docker-compose interface for restart containers
function composeRestart() {
	IMAGE_TAG=$IMAGETAG docker-compose -f $1 restart $CONTAINER
}

# Restart containers for the private network.
function restartContainers() {
	echo "---- Restart containers for the configured private network. ----"
	if [ "$SUBCOMMAND" == "p2p" ]; then
		for CONTAINER in peer0.example.com peer1.example.com; do
			composeRestart $COMPOSE_FILE_P2P
		done
	elif [ "$SUBCOMMAND" == "p2s" ]; then
		for CONTAINER in peer.example.com server.example.com; do
			composeRestart $COMPOSE_FILE_P2S
		done
	else
		for CONTAINER in peer0.example.com peer1.example.com server.example.com; do
			composeRestart $COMPOSE_FILE_P2SP
		done
	fi
}

# General interface for up and running a private network.
function networkUp() {
	if [ -d "$BUILD_PATH" ]; then
		generateKey
		createContainers
		copySwarmKey
		startContainers
		switchPrivateNet
		restartContainers
	fi
}

# Set and export environment variables from env file
function setEnv() {
	if [ "$SUBCOMMAND" == "p2p" ]; then
		set -a
		source $ENV_P2P
		set +a
	elif [ "$SUBCOMMAND" == "p2s" ]; then
		set -a
		source $ENV_P2S
		set +a
	else
		set -a
		source $ENV_P2SP
		set +a
	fi
}

# Start and up a peer to peer based private network
function p2pUp() {
	setEnv
	networkUp
	IMAGE_TAG=$IMAGETAG docker-compose -f $COMPOSE_FILE_P2P up -d --no-deps cli 2>&1
	if [ $? -ne 0 ]; then
		echo "ERROR!!! could not start p2p network, exit."
		exit 1
	fi
	# Run end to end tests
	$E2E_TEST $SUBCOMMAND peer0.example.com peer1.example.com
}

# Stop and clear peer to peer based private network
function p2pDown() {
	setEnv
	# Bring down the private network, and remove volumes.
	docker-compose -f $COMPOSE_FILE_P2P down --volumes --remove-orphans
	# Remove local ipfs config.
	rm -rf .ipfs/data .ipfs/staging
	if [ "$COMMAND" != "restart" ]; then
		docker run -v $PWD:/var/ipfsfb --rm ipfsfb/ipfs-tools:$IMAGETAG rm -rf /var/ipfsfb/peer /var/ipfsfb/data /var/ipfsfb/staging
		# Remove unwanted key file generated by swarmkeygen tool.
		rm -f $BUILD_PATH/*.key
	fi
}

# Start and up a peer to server based private network
function p2sUp() {
	setEnv
	networkUp
	IMAGE_TAG=$IMAGETAG docker-compose -f $COMPOSE_FILE_P2S up -d --no-deps cli 2>&1
	if [ $? -ne 0 ]; then
		echo "ERROR!!! could not start p2s network, exit."
		exit 1
	fi
	# Run end to end tests
	$E2E_TEST $SUBCOMMAND server.example.com peer.example.com
}

# Stop and clear peer to server based private network
function p2sDown() {
	setEnv
	# Bring down the private network, and remove volumes.
	docker-compose -f $COMPOSE_FILE_P2S down --volumes --remove-orphans
	# Remove local ipfs config.
	rm -rf .ipfs/data .ipfs/staging
	if [ "$COMMAND" != "restart" ]; then
		docker run -v $PWD:/var/ipfsfb --rm ipfsfb/ipfs-tools:$IMAGETAG rm -rf /var/ipfsfb/peer /var/ipfsfb/server /var/ipfsfb/data /var/ipfsfb/staging
		# Clean the network cache.
		docker network prune -f
		# Remove unwanted key file generated by swarmkeygen tool.
		rm -f $BUILD_PATH/*.key
	fi
}

# Start and up a peer to server and to peer based private network
function p2spUp() {
	setEnv
	networkUp
	IMAGE_TAG=$IMAGETAG docker-compose -f $COMPOSE_FILE_P2SP up -d --no-deps cli 2>&1
	if [ $? -ne 0 ]; then
		echo "ERROR!!! could not start p2s network, exit."
		exit 1
	fi
	# Run end to end tests
	$E2E_TEST $SUBCOMMAND server.example.com peer0.example.com peer1.example.com
}

# Stop and clear peer to server and to peer based private network
function p2spDown() {
	setEnv
	# Bring down the private network, and remove volumes.
	docker-compose -f $COMPOSE_FILE_P2SP down --volumes --remove-orphans
	# Remove local ipfs config.
	rm -rf .ipfs/data .ipfs/staging
	if [ "$COMMAND" != "restart" ]; then
		docker run -v $PWD:/var/ipfsfb --rm ipfsfb/ipfs-tools:$IMAGETAG rm -rf /var/ipfsfb/peer /var/ipfsfb/server /var/ipfsfb/data /var/ipfsfb/staging
		# Clean the network cache.
		docker network prune -f
		# Remove unwanted key file generated by swarmkeygen tool.
		rm -f $BUILD_PATH/*.key
	fi
}

# Set the network
NETWORK=simple-network
# Use default docker-compose file
COMPOSE_FILE=docker-compose.yml
# Environment file
ENV=.env
# Set end-to-end name space
E2E_NS=e2e
# End-to-end test file
E2E_TEST=$E2E_NS/test.sh
# Set networks docker-compose file
COMPOSE_FILE_P2P=./p2p/${COMPOSE_FILE}
COMPOSE_FILE_P2S=./p2s/${COMPOSE_FILE}
COMPOSE_FILE_P2SP=./p2sp/${COMPOSE_FILE}
# Set environment variable for docker-compose file
ENV_P2P=./p2p/${ENV}
ENV_P2S=./p2s/${ENV}
ENV_P2SP=./p2sp/${ENV}
# Set config path for travis
DIR=$(basename $PWD)
if [ "$DIR" != "$NETWORK" ]; then
else
	# Set networks docker-compose file for travis
	COMPOSE_FILE_P2P=./samples/${NETWORK}/p2p/${COMPOSE_FILE}
	COMPOSE_FILE_P2S=./samples/${NETWORK}/p2s/${COMPOSE_FILE}
	COMPOSE_FILE_P2SP=./samples/${NETWORK}/p2sp/${COMPOSE_FILE}
	# Set environment variable for docker-compose file for travis
	ENV_P2P=./samples/${NETWORK}/p2p/${ENV}
	ENV_P2S=./samples/${NETWORK}/p2s/${ENV}
	ENV_P2SP=./samples/${NETWORK}/p2sp/${ENV}
	E2E_TEST=./samples/${NETWORK}/${E2E_TEST}
fi
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
COMMAND=$1
SUBCOMMAND=$2
shift

# Command interface for execution
if [ "${COMMAND}" == "up" ]; then
	if [ "${SUBCOMMAND}" == "p2p" ]; then
		p2pUp
	elif [ "${SUBCOMMAND}" == "p2s" ]; then
		p2sUp
	elif [ "${SUBCOMMAND}" == "p2sp" ]; then
		p2spUp
	else
		printNetwork
		exit 1
	fi
elif [ "${COMMAND}" == "down" ]; then
	if [ "${SUBCOMMAND}" == "p2p" ]; then
		p2pDown
	elif [ "${SUBCOMMAND}" == "p2s" ]; then
		p2sDown
	elif [ "${SUBCOMMAND}" == "p2sp" ]; then
		p2spDown
	else
		printNetwork
		exit 1
	fi
elif [ "${COMMAND}" == "restart" ]; then
	if [ "${SUBCOMMAND}" == "p2p" ]; then
		p2pDown
		p2pUp
	elif [ "${SUBCOMMAND}" == "p2s" ]; then
		p2sDown
		p2sUp
	elif [ "${SUBCOMMAND}" == "p2sp" ]; then
		p2spDown
		p2spUp
	else
		printNetwork
		exit 1
	fi
elif [ "${COMMAND}" == "generate" ]; then
	generateKey
else
	printHelper
	exit 1
fi
