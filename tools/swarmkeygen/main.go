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
	"fmt"
	"os"

	"github.com/IBM/IPFSfB/tools/swarmkeygen/crypto"
	"github.com/IBM/IPFSfB/tools/swarmkeygen/encoder"
	"github.com/IBM/IPFSfB/tools/swarmkeygen/metadata"

	"gopkg.in/alecthomas/kingpin.v2"
)

// Command line setting
var (
	app = kingpin.New("swarmkeygen", "Utility of IPFS node keys generating.")

	genArg     = app.Command("generate", "Generate key for connecting swarm nodes.")
	versionArg = app.Command("version", "Show version information.")
	lenFlag    = app.Flag("length", "The length of the key.").Required().Int()
)

func main() {
	switch kingpin.MustParse(app.Parse(os.Args[1:])) {
	// "generate" command
	case genArg.FullCommand():
		generate()
	// "version" command
	case versionArg.FullCommand():
		printVersion()
	}
}

// Generate swarm key
func generate() {
	rndBytes, err := crypto.GenerateRandomBytes(*lenFlag)
	if err != nil {
		fmt.Printf("Could not read random source: %s", err)
		os.Exit(-1)
	}
	key := encoder.ParseRandomBytesToString(rndBytes)
	fmt.Println(key)
}

// Print version information
func printVersion() {
	fmt.Println(metadata.GetVersionInfo())
}
