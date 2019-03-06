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
ARG ALPINE_VER

FROM golang:${GO_VER}-alpine as builder
RUN apk add --no-cache \
        gcc \
        musl-dev \
        ca-certificates \
        curl \
        jq \
        wget \
        git \
        bash \
        make;

ADD . $GOPATH/src/github.com/IBM
WORKDIR $GOPATH/src/github.com/IBM
ENV EXECUTABLES go git
RUN git clone https://github.com/IBM/IPFSfB && \
    cd IPFSfB/ && \
    go get ./cmd/swarmkeygen && \
    go get -u github.com/ipfs/ipfs-update && \
    cd $GOPATH/src && \
    mkdir go-ipfs && \
    curl --silent "https://api.github.com/repos/ipfs/go-ipfs/releases/latest" | \
    jq -r '.assets[0].browser_download_url'| \
    wget -i - --no-check-certificate && \
    tar xvfz *.tar.gz -C go-ipfs && \
    cd go-ipfs/cmd/ipfs/dist && \
    ./install.sh

FROM alpine:${ALPINE_VER} as tools
ENV IPFS_PATH /data/ipfs
VOLUME /data/ipfs
COPY --from=builder /go/bin /usr/local/bin
