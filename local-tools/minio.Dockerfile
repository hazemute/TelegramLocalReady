FROM golang:1.24.8-alpine3.21 AS builder

WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -tags kqueue -trimpath -o /out/minio .

FROM alpine:3.21
COPY --from=builder /out/minio /usr/local/bin/minio
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
EXPOSE 9000 9001
ENTRYPOINT ["/usr/local/bin/minio"]
