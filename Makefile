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

# -------------------------------------------------------------
# This makefile defines the following targets
#
#   - all (default) - builds all targets and runs all non-integration tests/checks
#	- swarmkeygen - builds a native swarmkeygen library
#	- go-ipfs - builds the infrastructure to run ipfs
#	- clean - cleans the build area
# -------------------------------------------------------------

BASE_VERSION = 0.1.0
IMAGE_VERSION = 0.1.0
COMMIT_VERSION ?= $(shell git rev-parse --short HEAD)

BUILD_DIR ?= $(shell pwd)/.build
GOBIN = $(shell pwd)/.bin
GO_VER = $(shell grep -A1 'go:' .travis.yml | grep -v "go:" | cut -d'-' -f2- | cut -d' ' -f2-)
EXECUTABLES ?= go docker git curl
IMAGES = tools peer server
PACKAGES = swarmkeygen
ORG = IBM
PROJECT_NAME = IPFSfB
PROJECT_PATH = github.com/$(ORG)/$(PROJECT_NAME)

PROJECT_VER = ReleaseVersion=$(BASE_VERSION)
PROJECT_VER += ImageVersion=$(IMAGE_VERSION)
PROJECT_VER += CommitSHA=$(COMMIT_VERSION)

GO_LDFLAGS = $(patsubst %, -X $(PROJECT_PATH)/release.%,$(PROJECT_VER))

export GO_LDFLAGS

pkgmap.swarmkeygen := $(PROJECT_PATH)/cmd/swarmkeygen

.PHONY: all swarmkeygen clean

all: swarmkeygen ipfs

swarmkeygen: 
	GO_LDFLAGS=-X $(pkgmap.$(@F))/metadata.CommitSHA=$(COMMIT_VERSION)
	go get -ldflags "$(GO_LDFLAGS)" $(pkgmap.$(@F))	

ipfs:
	go get -ldflags "$(GO_LDFLAGS)" -u -d github.com/ipfs/go-ipfs
	cd $(GOPATH)/src/github.com/ipfs/go-ipfs
	make install

clean:
	rm -rf $(GOBIN)/*
