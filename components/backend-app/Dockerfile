FROM golang:1.20-alpine
RUN apk add --no-cache ca-certificates git
WORKDIR /app
COPY . .
RUN go mod init backend-app && \
    go mod tidy && \
    go build -o backend main.go

EXPOSE 8080
CMD ["./backend"]