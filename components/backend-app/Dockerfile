FROM golang:1.20-alpine

WORKDIR /app

# Copy go files
COPY go.mod go.sum* ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build with verbose output to see any errors
RUN go build -v -o backend main.go

EXPOSE 8080
CMD ["./backend"]