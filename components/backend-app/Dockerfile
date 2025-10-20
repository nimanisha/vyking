FROM golang:1.20-alpine AS builder
WORKDIR /src
COPY . .
RUN go build -o /bin/backend main.go

FROM alpine:3.18
RUN apk add --no-cache ca-certificates
COPY --from=builder /bin/backend /usr/local/bin/backend
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/backend"]
