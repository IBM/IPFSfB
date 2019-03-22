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

# A script to the end-to-end test for all private network scenarios (p2p, p2s, p2sp)

echo "----------------------------------------------------------"
echo "---- Now run end-to-end test for the private network. ----"
echo "----------------------------------------------------------"
echo " _____ ____  _____ "
echo "| ____|___ \| ____|"
echo "|  _|   __) |  _|  "
echo "| |___ / __/| |___ "
echo "|_____|_____|_____|"
echo

# Set local environment
export PATH=${PWD}:$PATH
export LOG_PATH=${PWD}/.ipfs/data

# Set environment variable, CONTAINER, CNAME, and N are represent to each containers
NETWORK=$1
CONTAINER=$2
CNAME=$3
N=$4

testFiles() {
    # Upload file
    echo "---- Uploading file to IPFS... ----"
    docker exec $CONTAINER e2e/utils.sh uploadFiles $NETWORK
    # View file
    echo "---- Viewing file from IPFS... ----"
    docker cp -a $LOG_PATH/log.txt $CNAME:/var/ipfsfb/data
    docker exec $CNAME e2e/utils.sh viewFiles $NETWORK
    # if network is p2sp, tests the third container
    if [ "$NETWORK" == "p2sp" ]; then
        docker cp -a $LOG_PATH/log.txt $N:/var/ipfsfb/data
        docker exec $N e2e/utils.sh viewFiles $NETWORK
    fi
    # Download file
    echo "---- Downloading file from IPFS... ----"
    docker exec $CNAME e2e/utils.sh downloadFiles $NETWORK
    # if network is p2sp, tests the third container
    if [ "$NETWORK" == "p2sp" ]; then
        docker exec $N e2e/utils.sh downloadFiles $NETWORK
    fi
}

testWebs() {
    # Publish web
    echo "---- Publishing web to IPFS... ----"
    docker exec $CONTAINER e2e/utils.sh publishWeb $NETWORK
    # Query web content
    echo "---- Querying web content from IPFS... ----"
    docker cp -a $LOG_PATH/log.txt $CNAME:/var/ipfsfb/data
    docker exec $CNAME e2e/utils.sh queryWeb $NETWORK
    # if network is p2sp, tests the third container
    if [ "$NETWORK" == "p2sp" ]; then
        docker cp -a $LOG_PATH/log.txt $N:/var/ipfsfb/data
        docker exec $N e2e/utils.sh queryWeb $NETWORK
    fi
}

# Test file related operations
echo "Testing file related operations..."
testFiles
# Test web related operations
echo "Testing web related operations..."
testWebs

exit 0
