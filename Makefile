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
#	- clean - cleans the build area

BUILD_DIR ?= $(GOPATH)/src/$(PROJECT_PATH)
GO_VER = $(shell grep -A1 'go:' .travis.yml | grep -v "go:" | cut -d'-' -f2- | cut -d' ' -f2-)
GOBIN = $(shell pwd)/build/bin
HASH_VERSION ?= $(shell git rev-parse --short HEAD)
EXECUTABLES ?= go docker git curl
IMAGES = tools
PACKAGES = swarmkeygen
ORG = IBM
PROJECT_NAME = IPFSfB
PROJECT_PATH = github.com/$(ORG)/$(PROJECT_NAME)
BASE_VERSION = 0.1.0
ARCH = $(shell go env GOARCH)
PROJECT_VERSION=$(BASE_VERSION)-snapshot
DOCKER_TAG = $(ARCH)-$(PROJECT_VERSION)
DUMMY = .dummy-$(DOCKER_TAG)

pkgmap.swarmkeygen := $(PROJECT_PATH)/cmd/swarmkeygen

.PHONY: all swarmkeygen docker-tools

# docker-tools:
# 	$(BUILD_DIR)/images/tools/$(DUMMY)

swarmkeygen: 
	GO_LDFLAGS=-X $(pkgmap.$(@F))/metadata.CommitSHA=$(HASH_VERSION)
	go get -ldflags $(GO_LDFLAGS) ./cmd/swarmkeygen
