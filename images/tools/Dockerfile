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

ARG GO_VERSION

FROM golang:${GO_VERSION}-alpine as build
RUN apk add --no-cache \
        gcc \
        bash \
        git \
        make;

ADD . $GOPATH/src/github.com/IBM/IPFSfB
WORKDIR $GOPATH/src/github.com/IBM/IPFSfB
ENV EXECUTABLES go git

FROM golang as tools
RUN make swarmkeygen

FROM golang:${GO_VERSION}-alpine
RUN apk add --no-cache \
    bash;
ENV IPFS_PATH /data/ipfs
VOLUME /data/ipfs
COPY --from=tools /go/src/github.com/IBM/IPFSfB/.build/bin /usr/local/bin
EXPOSE 4001 5001 8080 8081