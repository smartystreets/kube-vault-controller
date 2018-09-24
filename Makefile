#!/usr/bin/make -f

NAME  := kube-vault-controller
REPO  ?= $(or ${DOCKER_SERVER},smartystreets)
IMAGE := $(REPO)/$(NAME):$(or ${VERSION},local)

PACKAGES := $(shell go list ./... | grep -v /vendor/)
.PHONY: build generate clean compile check test image publish image-debug images

build: clean test compile

generate:
	go generate ${PACKAGES}

clean:
	rm -rf workspace

compile:
	GOOS="$(OS)" GOARCH="$(CPU)" CGO_ENABLED=0 go build $(GO_FLAGS) -o workspace/app .

check:
	go vet ${PACKAGES}

test:
#	// -race requires CGO_ENABLED=1; which needs gcc, muscl-dev
	go test -v ${PACKAGES} -race -cover -p=1

##########################################################

image: OS ?= linux
image: CPU ?= amd64
image: build
	docker build . $(DOCKER_FLAGS) -t "$(IMAGE)"

publish: image
	docker push "$(IMAGE)"

image-debug: DOCKER_FLAGS := -f Dockerfile.debug
image-debug: GO_FLAGS := -gcflags "all=-N -l"
image-debug: IMAGE := $(IMAGE)-debug
image-debug: image

images: image
	$(MAKE) image-debug
