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

# This will ensure that we have the correct config path, and set init profile.
export PATH=${PWD}:$PATH
export IPFS_CONFIG=${IPFS_PATH}/config
export SWARM_KEY_FILE=${IPFS_PATH}/swarm.key

# Print the help message.
function printHelper () {
    echo "Usage: "
    echo "  config.sh init   - initialize IPFS config if not already initialized."
    echo "  config.sh daemon - run IPFS daemon process for target network."
    echo "Flags: "
    echo "  -p <profile> - the IPFS profile for initialization."
    echo "  --routing <routing> - overrides the routing option (defaults to default)."
}

# Check whether ipfs configuration file already exists.
function init () {
    if [ ! -e "$IPFS_CONFIG" ]; then
        echo "---- No IPFS configuration file found, ${MESSAGE}... ----"
        ipfs init
    fi
}

# Running IPFS daemon process.
function daemon () {
    if [ ! -e "$SWARM_KEY_FILE" ]; then
        echo "---- Swarm key file not found, ${MESSAGE} a default network. ----"
    else
        echo "---- ${MESSAGE} a private network with a swarm key file. ----"
        export $LIBP2P_FORCE_PNET
    fi
    ipfs daemon
}

# Set private network
LIBP2P_FORCE_PNET=1

# The arg of the command
COMMAND=$1;shift

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