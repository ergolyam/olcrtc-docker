FROM docker.io/golang:1.27-alpine3.24 AS builder

WORKDIR /build

RUN wget -O- https://github.com/openlibrecommunity/olcrtc/archive/refs/heads/master.tar.gz | tar xzf - --strip-components=1

ENV CGO_ENABLED=0

RUN go build -trimpath -ldflags="-s" -o /app/ ./cmd/... && \
    rm -rf /build/*


FROM docker.io/busybox:stable-uclibc AS main

COPY --from=builder /app/ /usr/local/bin/

ENTRYPOINT [ "/usr/local/bin/olcrtc" ]

CMD [ "/data/config.yaml" ]
