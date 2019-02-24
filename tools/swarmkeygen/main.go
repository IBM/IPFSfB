/*
Copyright 2019 IBM Corp.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package main

import (
	"flag"
	"fmt"
	"os"

	"github.com/IBM/IPFSfB/tools/swarmkeygen/crypto"
	"github.com/IBM/IPFSfB/tools/swarmkeygen/encoder"
	"github.com/IBM/IPFSfB/tools/swarmkeygen/metadata"
)

// Command line flags
var (
	genFlag = flag.Bool("generate", false, "Generate key for connecting swarm nodes")
	versionFlag = flag.Bool("version", false, "Show version information")
)

// Set key length
var length = 32

func main() {
	// Parse inputs
	flag.Parse()

	// Generate key file
	if *genFlag {
		key, err := generate(length)
		if err != nil {
			fmt.Printf("Error on generate: %s", err)
			os.Exit(-1)
		}
		fmt.Println(key)
	}

	// Show version
	if *versionFlag {
		printVersion()
		os.Exit(0)
	}
}

// Generate swarm key
func generate(length int) (string, error) {
	rndBytes, err := crypto.GenerateRandomBytes(32)
	if err != nil {
		fmt.Printf("Could not read random source: %s", err)
	}
	return encoder.ParseRandomBytesToString(rndBytes), nil
}

// Print version information
func printVersion() {
	fmt.Println(metadata.GetVersionInfo())
}
