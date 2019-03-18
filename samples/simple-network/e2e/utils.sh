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
NETWORK=$1
IPFS_PATH=/var/ipfsfb
IPNS_PREFIX=/ipns
PEER_CONFIG_PATH=${IPFS_PATH}/peer
VALIDED_TIME=8760h

PEER_SRC_PATH=/go/src/github.com/ipfsfb/p2p/peer/artifacts/
if [ "$NETWORK" == "p2s"]; then
    PEER_SRC_PATH=/go/src/github.com/ipfsfb/p2s/peer/artifacts/
    SERVER_SRC_PATH=/go/src/github.com/ipfsfb/p2s/server/artifacts/
else
    PEER_SRC_PATH=/go/src/github.com/ipfsfb/p2sp/peer/artifacts/
    SERVER_SRC_PATH=/go/src/github.com/ipfsfb/p2sp/server/artifacts/
fi

FILE_TYPE=txt
WEB_TYPE=html
FILE_NAME=text_example.${FILE_TYPE}
WEB_NAME=web_example.${WEB_TYPE}

verifyResult() {
    if [ $1 -ne 0 ]; then
        echo "---- $2 ----"
        echo
        echo "---- Failed to excute end-to-end test, exit. ----"
        echo
        exit 1
    fi 
}

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

viewFiles() {
    set -x
    ipfs cat $HASH >&log.txt
    res=$?
    set+x
    cat log.txt
    verifyResult $res "Error!!! Unable to view files from IPFS on ${IPFS_HOST}."
    echo "---- View a file $HASH from IPFS on ${IPFS_HOST} on the private network '$NETWORK'."
}

downloadFiles() {
    set -x
    ipfs get $HASH -o ${PEER_CONFIG_PATH}/${FILE_NAME} >&log.txt
    res=$?
    set+x
    cat log.txt
    verifyResult $res "Error!!! Unable to download files from IPFS on ${IPFS_HOST}."
    echo "---- Successful downloaded a file ${FILE_NAME} from IPFS on ${IPFS_HOST} on the private network '$NETWORK'."
}

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

queryWeb() {
    set -x
    ipfs cat $IPFS_HASH/${WEB_NAME} >&log.txt
    res=$?
    set+x
    cat log.txt
    verifyResult $res "Error!!! Unable to query website contents from IPFS on ${IPFS_HOST}."
    echo "---- Successful queried a web content $IPFS_HASH/${WEB_NAME} from IPFS on ${IPFS_HOST} on the private network '$NETWORK'."
    if [ "$NETWORK" != "p2p"]; then
        set -x
        ipfs cat $IPNS_PREFIX/$IPNS_HASH >&log.txt
        res=$?
        set+x
        cat log.txt
        verifyResult $res "Error!!! Unable to query website contents from IPNS on ${IPFS_HOST}."
        echo "---- Successful queried a web content $IPNS_PREFIX/$IPNS_HASH from IPNS on ${IPFS_HOST} on the private network '$NETWORK'."
    fi
}
