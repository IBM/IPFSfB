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
export IPFS_PROFILE=$2
export IPFS_PATH=$3
export IPFS_CONFIG=${IPFS_PATH}/config

# Print the help message.
function printHelper () {
    echo "Usage: "
    echo "  config.sh init - initialize IPFS config if not already initialized."
}

# Check whether ipfs configuration file already exists.
function init () {
    if [ ! -s "$IPFS_CONFIG" ]; then
        echo "---- No IPFS config found, initializing... ----"
        if [ "$IPFS_PROFILE" == " " ]; then
            ipfs init
        else
            ipfs init -p $IPFS_PROFILE
        fi
    fi
}

# The arg of the command
MODE=$1;shift

# Command
if [ "${MODE}" == "init" ]; then
    init
else
    printHelper
    exit 1
fi