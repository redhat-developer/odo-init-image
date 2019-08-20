package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"os"
)

// imageMappingsFileEnv is env variable that points to image-mappings.json file
const imageMappingsFileEnv string = "ODO_IMAGE_MAPPINGS_FILE"

// builderImageNameEnv in env variable with name of the image ("name" label on the image)
const builderImageNameEnv string = "ODO_S2I_BUILDER_IMG"

// Lang stores list of image names associated to language
type Lang struct {
	Language string
	Images   []string
}

// ImageMappings hold mappings of language to image name
// the structure represents image-mappings.json file
type ImageMappings []Lang

// GetLanguage returns language name name for associated to imageName
func (im ImageMappings) GetLanguage(imageName string) string {
	for _, lang := range im {
		for _, image := range lang.Images {
			if image == imageName {
				return lang.Language
			}
		}
	}
	return ""
}

func main() {
	// json file where all the mappings of language to image name is stored
	// see ImageMappings for json structure
	imageMappingFile := os.Getenv(imageMappingsFileEnv)

	// name of the current image, we will try to find what language this is based on ImageMappings
	imageName := os.Getenv(builderImageNameEnv)

	var imageMappings ImageMappings

	file, err := os.Open(imageMappingFile)
	defer file.Close()
	if err != nil {
		log.Fatalln(err)
	}

	mappings, err := ioutil.ReadAll(file)
	if err != nil {
		log.Fatalln(err)
	}

	err = json.Unmarshal(mappings, &imageMappings)
	if err != nil {
		log.Fatalln(err)
	}

	lang := imageMappings.GetLanguage(imageName)

	fmt.Print(lang)
}
