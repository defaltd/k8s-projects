FROM golang:1.13.2-alpine as build

WORKDIR /app

COPY go.mod .

RUN go mod download

COPY . .

RUN go build -o main .

FROM golang:1.13.2-alpine

COPY --from=build /app .

EXPOSE 8080

CMD [ "./main" ]
