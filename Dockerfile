# Use an official alpine image
FROM alpine:3.20 AS builder

# Install necessary build tools
RUN apk add --no-cache curl wget tar git bash expect coreutils util-linux ca-certificates libc6-compat sudo build-base

# Set default shell to bash
SHELL ["/bin/bash", "-c"]

# Define Go version as a build argument
ARG GO_VERSION=1.23.1

# Determine the architecture and download the appropriate Go binary
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        GO_BINARY="go${GO_VERSION}.linux-amd64.tar.gz"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        GO_BINARY="go${GO_VERSION}.linux-arm64.tar.gz"; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    curl -LO "https://golang.org/dl/${GO_BINARY}" && \
    tar -C /usr/local -xzf "${GO_BINARY}" && \
    rm "${GO_BINARY}"

# Set the Go environment variables
ENV GO111MODULE=on \
    GOROOT=/usr/local/go \
    GOPATH=/go \
    PATH="${PATH}:/go/bin:/usr/local/go/bin:/usr/local/bin:/usr/bin:/bin:/sbin:/usr/sbin"

RUN go install github.com/goreleaser/goreleaser/v2@v2.2.0 && goreleaser --version

# Set the working directory
WORKDIR /src

# Copy the Go module files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy the rest of the application code
COPY . .

# Build the Go binaries using Goreleaser
RUN goreleaser release --snapshot

CMD ["sleep", "1"]
