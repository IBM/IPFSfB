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

ARG GO_VER

FROM golang:${GO_VER}-alpine as builder
RUN apk add --no-cache \
        gcc \
        musl-dev \
        git \
        bash \
        make;

ADD . $GOPATH/src/github.com/IBM/IPFSfB
WORKDIR $GOPATH/src/github.com/IBM/IPFSfB
ENV EXECUTABLES go git

FROM golang:${GO_VER} as peer
ENV IPFS_PATH /var/ipfsfb
VOLUME /var/ipfsfb
RUN go get github.com/ericchiang/pup && \
    apt-get update && apt-get install -y jq && \
    curl --silent "https://api.github.com/repos/ipfs/go-ipfs/releases/latest" | \
    jq -r '.assets[21].browser_download_url'| \
    wget -qi - && \
    tar xvfz *.tar.gz && \
    rm *.tar.gz && \
    cd go-ipfs && \
    ./install.sh
    
EXPOSE 4001 5001 8080 8081
CMD [ "ipfs", "daemon" ]