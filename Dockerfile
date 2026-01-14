FROM golang:1.23-alpine AS builder

WORKDIR /build

# Copy go module files
COPY dockadvisor/go.mod dockadvisor/go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY dockadvisor/ ./

# Build the CLI binary
RUN go build -o dockadvisor ./cmd/dockadvisor

# Final stage
FROM alpine:latest

# Install bash for the entrypoint script
RUN apk add --no-cache bash

WORKDIR /app

# Copy the binary from builder
COPY --from=builder /build/dockadvisor /usr/local/bin/dockadvisor

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
