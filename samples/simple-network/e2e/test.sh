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

# A script to the end-to-end test for IPFS private network.

echo " _____ ____  _____ "
echo "| ____|___ \| ____|"
echo "|  _|   __) |  _|  "
echo "| |___ / __/| |___ "
echo "|_____|_____|_____|"
echo
echo "----------------------------------------------------------"
echo "---- Now run end-to-end test for the private network. ----"
echo "----------------------------------------------------------"

# Set environment variable, CONTAINER, CNAME, and N are represent to each containers
NETWORK=$1
CONTAINER=$2
CNAME=$3
N=$4

# Import utils
. e2e/utils.sh

# Set utils environment
setGlobals $NETWORK

testFiles() {
    # Upload file
    echo "---- Uploading file to IPFS... ----"
    docker exec $CONTAINER . uploadFiles
    # View file
    echo "---- Viewing file from IPFS... ----"
    docker exec $CNAME . viewFiles
    # if containers are equal to 3, tests the third container
    if [ ! -n "$N" ]; then
        docker exec $N . viewFiles
    fi
    # Download file
    echo "---- Downloading file from IPFS... ----"
    docker exec $CNAME . downloadFiles
    # if containers are equal to 3, tests the third container
    if [ ! -n "$N" ]; then
        docker exec $N . downloadFiles
    fi
    res=$?
    verifyResult $res "File tests failed."
    echo "---- File tests passed on '$NETWORK'. ----"
}

testWebs() {
    # Publish web
    echo "---- Publishing web to IPFS... ----"
    docker exec $CONTAINER . publishWeb
    # Query web content
    echo "---- Querying web content from IPFS... ----"
    docker exec $CNAME . queryWeb
    # if containers are equal to 3, tests the third container
    if [ ! -n "$N" ]; then
        docker exec $N . queryWeb
    fi
    res=$?
    verifyResult $res "Web tests failed."
    echo "---- Web tests passed on '$NETWORK'. ----"
}

# Test file related operations
echo "Testing file related operations..."
testFiles
# Test web related operations
echo "Testing web related operations..."
testWebs

echo "-------------------------------------------------------------------------"
echo "---- All TESTS PASSED, running on a configured ipfs private network. ----"
echo "-------------------------------------------------------------------------"

exit 0