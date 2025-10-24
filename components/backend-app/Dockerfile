FROM golang:1.20-alpine AS builder
RUN apk add --no-cache ca-certificates git

WORKDIR /app
COPY main.go .

RUN echo 'module backend-app\n\ngo 1.20\n\nrequire github.com/go-sql-driver/mysql v1.7.1' > go.mod && \
    go mod download && \
    go build -o backend main.go

EXPOSE 8080

CMD ["./backend"]