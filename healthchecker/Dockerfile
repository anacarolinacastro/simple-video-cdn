FROM golang:latest 
RUN mkdir /app 
COPY healthchecker.go /app
WORKDIR /app 
RUN go build -o healthchecker . 
RUN ["chmod", "+x", "/app/healthchecker"]
CMD ["/app/healthchecker"]