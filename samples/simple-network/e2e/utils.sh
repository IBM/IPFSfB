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

# This file contains serveral utils to help test end-to-end tests.

# Set environment variable
IPNS_PREFIX=/ipns
PEER_CONFIG_PATH=${IPFS_PATH}/peer
VALIDED_TIME=8760h

# Set file and web
FILE_TYPE=txt
WEB_TYPE=html
FILE_NAME=file_example.${FILE_TYPE}
WEB_NAME=web_example.${WEB_TYPE}

# Verify execution result
verifyResult() {
    if [ $1 -ne 0 ]; then
        echo "---- $2 ----"
        echo
        echo "---- Failed to excute end-to-end test, exit. ----"
        echo
        exit 1
    fi 
}

# Set enviroment and path
setGlobals() {
    NETWORK_TYPE=$1
    if [ "$NETWORK_TYPE" == "p2p"]; then
        NETWORK=p2p
        PEER_SRC_PATH=/go/src/github.com/ipfsfb/p2p/peer/artifacts/
    elif [ "$NETWORK_TYPE" == "p2s"]; then
        NETWORK=p2s
        PEER_SRC_PATH=/go/src/github.com/ipfsfb/p2s/peer/artifacts/
        SERVER_SRC_PATH=/go/src/github.com/ipfsfb/p2s/server/artifacts/
    else
        NETWORK=p2sp
        PEER_SRC_PATH=/go/src/github.com/ipfsfb/p2sp/peer/artifacts/
        SERVER_SRC_PATH=/go/src/github.com/ipfsfb/p2sp/server/artifacts/
}

# Upload files to IPFS
uploadFiles() {
    set -x
    if [ "$NETWORK" == "p2p"]; then
        ipfs add -q ${PEER_SRC_PATH}/${FILE_NAME} >&log.txt
    else
        ipfs add -q ${SERVER_SRC_PATH}/${FILE_NAME} >&log.txt
    fi
    res=$?
    set+x
    cat log.txt
    HASH=$(cat log.txt)
    verifyResult $res "Error!!! Unable to upload files to IPFS on ${IPFS_HOST}."
    echo "---- Successful uploaded file ${FILE_NAME} to IPFS on ${IPFS_HOST} on the private network '$NETWORK'."
}

# View files from IPFS
viewFiles() {
    set -x
    ipfs cat $HASH >&log.txt
    res=$?
    set+x
    cat log.txt
    verifyResult $res "Error!!! Unable to view files from IPFS on ${IPFS_HOST}."
    echo "---- View a file $HASH from IPFS on ${IPFS_HOST} on the private network '$NETWORK'."
}

# Download files from IPFS
downloadFiles() {
    set -x
    ipfs get $HASH -o ${PEER_CONFIG_PATH}/${FILE_NAME} >&log.txt
    res=$?
    set+x
    cat log.txt
    verifyResult $res "Error!!! Unable to download files from IPFS on ${IPFS_HOST}."
    echo "---- Successful downloaded a file ${FILE_NAME} from IPFS on ${IPFS_HOST} on the private network '$NETWORK'."
}

# Publish web to IPFS
publishWeb() {
    set -x
    if [ "$NETWORK" == "p2p"]; then
        ipfs add -wq ${PEER_SRC_PATH}/${WEB_NAME} >&log.txt
    else
        ipfs add -wq ${SERVER_SRC_PATH}/${WEB_NAME} >&log.txt
    fi
    res=$?
    set+x
    cat log.txt
    verifyResult $res "Error!!! Unable to publish websites to IPFS on ${IPFS_HOST}."
    echo "---- Successful published a web ${WEB_NAME} to IPFS on ${IPFS_HOST} on the private network '$NETWORK'."
    if [ "$NETWORK" != "p2p"]; then
        IPFS_HASH=$(cat log.txt | tail -n 1)
        set -x
        ipfs name publish -t $VALIDED_TIME -Q $IPFS_HASH >&log.txt
        IPNS_HASH=$(cat log.txt | tail -n 1)
        ipfs name resolve $IPNS_HASH >&log.txt
        res=$?
        set+x
        cat log.txt
        verifyResult $res "Error!!! Unable to publish websites to IPNS on ${IPFS_HOST}."
        echo "---- Successful published a web ${WEB_NAME} to IPNS on ${IPFS_HOST} on the private network '$NETWORK'."
    fi
}

# Query web content from IPFS
queryWeb() {
    set -x
    pup -f <(ipfs cat $IPFS_HASH/${WEB_NAME}) pre text{} >&log.txt
    res=$?
    set+x
    cat log.txt
    verifyResult $res "Error!!! Unable to query website contents from IPFS on ${IPFS_HOST}."
    echo "---- Successful queried a web content $IPFS_HASH/${WEB_NAME} from IPFS on ${IPFS_HOST} on the private network '$NETWORK'."
    if [ "$NETWORK" != "p2p"]; then
        set -x
        pup -f <(ipfs cat $IPNS_PREFIX/$IPNS_HASH) pre text{} >&log.txt
        res=$?
        set+x
        cat log.txt
        verifyResult $res "Error!!! Unable to query website contents from IPNS on ${IPFS_HOST}."
        echo "---- Successful queried a web content $IPNS_PREFIX/$IPNS_HASH from IPNS on ${IPFS_HOST} on the private network '$NETWORK'."
    fi
}

# The arg of the command
COMMAND=$1
shift

# Command interface for execution
if [ "${COMMAND}" == "uploadFiles" ]; then
	uploadFiles
elif [ "${COMMAND}" == "viewFiles" ]; then
	viewFiles
elif [ "${COMMAND}" == "downloadFiles" ]; then
    downloadFiles
elif [ "${COMMAND}" == "publishWeb" ]; then
    publishWeb
elif [ "${COMMAND}" == "queryWeb" ]; then
    queryWeb
else
	exit 1
fi
