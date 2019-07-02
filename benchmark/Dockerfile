FROM golang:latest

RUN mkdir /app
WORKDIR /app

RUN go get github.com/tsliwowicz/go-wrk
RUN go build -o go-wrk /go/src/github.com/tsliwowicz/go-wrk

ENTRYPOINT [ "/app/go-wrk" ]

