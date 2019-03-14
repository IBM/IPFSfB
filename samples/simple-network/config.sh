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

# The file will ensure that each nodes (whether servers or peers) have different peer id.
# This will be significant because we use different id to identify each peer or servers,
# and connect them to one network.

# This will ensure that we have the correct config path, and set init profile.
export PATH=${PWD}:$PATH
export IPFS_CONFIG=${IPFS_PATH}/config
export SWARM_KEY_FILE=${IPFS_PATH}/swarm.key

# Print the help message.
function printHelper() {
	echo "Usage: "
	echo "  config.sh init - initialize IPFS config if not already initialized."
	echo "  config.sh daemon - run IPFS daemon process for target network."
	echo "Flags: "
    echo "  -p <profile> - the IPFS profile for initialization (defaults to default-networking)."
    echo "  -r <routing> - routing option for IPFS node (defaults to default)."
	echo "	-m <migrate> - option for auto repo migration (defaults to false)."
}

# Check whether ipfs configuration file already exists.
function init() {
	if [ ! -e "$IPFS_CONFIG" ]; then
		echo "---- No IPFS configuration file found, ${MESSAGE}... ----"
		ipfs init --profile=$PROFILE
	fi
}

# Running IPFS daemon process.
function daemon() {
	if [ ! -e "$SWARM_KEY_FILE" ]; then
		echo "---- Swarm key file not found, ${MESSAGE} a default network. ----"
	else
		echo "---- ${MESSAGE} a private network with a swarm key file. ----"
		set -x
		LIBP2P_FORCE_PNET=$PNET
		set +x
	fi
	ipfs daemon --routing=$ROUTING --migrate=$MIGRATE
}

# Set private network
PNET=1
# Set config profile
PROFILE=default-networking
# Set routing option
ROUTING=default
# Set repo migration
MIGRATE=false

# The arg of the command
COMMAND=$1
shift

# Options for running command
while getopts "h?p:r:m" opt; do
	case "$opt" in
	h | \?)
		printHelper
		exit 0
		;;
	p)
		PROFILE=$OPTARG
		;;
	r)
		ROUTING=$OPTARG
		;;
	m)
		MIGRATE=true
		;;
	esac
done

# Command interface for message
if [ "$COMMAND" == "init" ]; then
	MESSAGE="Initializing"
elif [ "$COMMAND" == "daemon" ]; then
	MESSAGE="Starting"
else
	printHelper
	exit 1
fi

# Command interface for execution
if [ "${COMMAND}" == "init" ]; then
	init
elif [ "${COMMAND}" == "daemon" ]; then
	daemon
else
	printHelper
	exit 1
fi
