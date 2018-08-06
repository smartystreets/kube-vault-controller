### Build Image

FROM golang:1.10-alpine AS build
ARG BIN=kube-vault-controller
ARG PROJECT=github.com/roboll/$BIN
WORKDIR /go/src/$PROJECT/

# Install tools required for project
# Run `docker build --no-cache .` to update dependencies
RUN apk add \
	git \
	make \
	--no-cache

#RUN go get github.com/golang/dep/cmd/dep
# Manage project dependencies with Gopkg.toml and Gopkg.lock
# These layers are only re-built when Gopkg files are updated
#COPY Gopkg.lock Gopkg.toml /go/src/project/
#RUN dep ensure -vendor-only

# Copy the entire project and build it
# This layer is rebuilt when a file changes in the project directory
COPY . .
RUN mkdir -p /deploy/etc/ssl/certs && \
	cp -p /etc/ssl/certs/ca-certificates.crt /deploy/etc/ssl/certs/ca-certificates.crt && \
	make build && \
#	make test && \
    cp -p $BIN /deploy/app



### Release Image

FROM scratch
COPY --from=build /deploy /
ENTRYPOINT ["/app"]
