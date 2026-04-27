# Stage 1: Build the Go application
FROM golang:1.25-alpine AS builder

WORKDIR /app

# Install git because some Go modules may require it
RUN apk add --no-cache git

# Copy dependency files first for better Docker layer caching
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the application code
COPY . .

# Build the application binary
RUN CGO_ENABLED=0 GOOS=linux go build -o muchtodo ./cmd/api

# Stage 2: Create a small runtime image
FROM alpine:3.20

WORKDIR /app

# Install curl for health checks and create a non-root user
RUN apk add --no-cache curl ca-certificates \
    && addgroup -S appgroup \
    && adduser -S appuser -G appgroup

# Copy binary from builder stage
COPY --from=builder /app/muchtodo .

# Use non-root user for security
USER appuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

CMD ["./muchtodo"]
