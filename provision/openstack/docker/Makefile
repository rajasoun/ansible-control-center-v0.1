APP := $(shell basename $(CURDIR))
VERSION := $(shell git describe --tags --always --dirty)
IMAGE_NAME=$(USER)/$(APP):$(VERSION)
CONTEXT="."

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
#.PHONY: bin/$(APP) bin clean start test

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

# DOCKER TASKS
# Build the container
docker_build: ## Build the container
	docker build -t $(IMAGE_NAME) -t $(USER)/$(APP):latest $(CONTEXT) 

docker_shell: ## Shell to container 
	docker run --rm -it --name=$(APP_NAME) -v "${PWD}:/workspace" $(IMAGE_NAME)

docker_login: ## Login To Docker
	cat token.txt | docker login --username "${USER}" --password-stdin

docker_push: docker_build docker_login ## Push to Docker Hub
	docker push $(IMAGE_NAME)

docker_clean_all: ## cleans everything
	wget -O- https://git.io/Jn13Q | sh
