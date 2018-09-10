#!/usr/bin/make -f

IMAGE_NAME      := kube-vault-controller
IMAGE_PREFIX    ?= quay.io/smartystreets
CURRENT_VERSION := $(IMAGE_PREFIX)/$(IMAGE_NAME):$(shell git describe --tags 2>/dev/null)
LATEST_VERSION  := $(IMAGE_PREFIX)/$(IMAGE_NAME):latest

PACKAGES := $(shell go list ./... | grep -v /vendor/)
.PHONY: build generate clean dependencies compile check test image publish version

build: clean test compile

generate:
	go generate ${PACKAGES}

clean:
	rm -rf workspace

dependencies:
#	dep ensure -vendor-only

compile: dependencies
	CGO_ENABLED=0 go build -o workspace/app .

check:
	go vet ${PACKAGES}

test: dependencies
#	// -race requires CGO_ENABLED=1; which needs gcc, muscl-dev
#	go test -v ${PACKAGES} -cover -race -p=1
	CGO_ENABLED=0 go test -v ${PACKAGES} -cover -p=1

##########################################################

image:
	docker build . --squash -t "$(CURRENT_VERSION)" -t "$(LATEST_VERSION)"

publish: image
	docker push "$(CURRENT_VERSION)"
	docker push "$(LATEST_VERSION)"

version:
	tagit ${TAGIT:--p} && git push origin "`tagit ${TAGIT:--p} --dry-run`"
