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

BUILD_DIR ?= .build
GO_VERSION = $(shell grep -A1 'go:' .travis.yml | grep -v "go:" | cut -d'-' -f2- | cut -d' ' -f2-)
EXECUTABLES ?= go docker git
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

tools.swarmkeygen := $(PROJECT_PATH)/cmd/swarmkeygen

.PHONY: docker-tools
docker-tools: $(BUILD_DIR)/images/tools/$(DUMMY)

.PHONY: swarmkeygen
swarmkeygen: $(BUILD_DIR)/bin/swarmkeygen
