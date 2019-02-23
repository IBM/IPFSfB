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
	"log"
	"os"

	"github.com/IBM/IPFSfB/tools/swarmkeygen/crypto"
	"github.com/IBM/IPFSfB/tools/swarmkeygen/encoder"
	"github.com/IBM/IPFSfB/tools/swarmkeygen/metadata"
)

// Set exit code
var exitCode = 0

// Generate swarm key
func doGenerate(length int) error {
	log.Println("Generating new swarm key")
	rndBytes, err := crypto.generateRandomBytes(32)
	if err != nil {
		fmt.Errorf("Could not read random source: %s", err)
	}
	key := encoder.parseRandomBytesToString(rndBytes)
	fmt.Println(key)
	return nil
}

func main() {
	var generate string

	flag.StringVar(&generate, "generate", "", "generate key for connecting swarm nodes.")

	version := flag.Bool("version", false, "show version information.")

	flag.Parse()

	if *version {
		printVersion()
		os.Exit(exitCode)
	}

	var length = 32

	if generate != "" {
		if err := doGenerate(length); err != nil {
			log.Fatalf("Error on generate: %s", err)
		}
	}
}

// Print version information
func printVersion() {
	fmt.Println(metadata.getVersionInfo())
}
