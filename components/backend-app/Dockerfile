FROM golang:1.20-alpine
#Backend
RUN apk add --no-cache ca-certificates git

WORKDIR /app

COPY go.mod ./

COPY . .

RUN go mod tidy && go build -o backend main.go

EXPOSE 8080

CMD ["./backend"]