# olcrtc-docker

Lightweight container image for [olcRTC](https://github.com/openlibrecommunity/olcrtc), an encrypted TCP-over-WebRTC tunnel.

## Initial Setup

### Build

```bash
docker build -t olcrtc .
```

### Pull

```bash
docker pull ghcr.io/ergolyam/olcrtc-docker:latest
```

## Configuration

The container reads `/data/config.yaml` by default. Generate a 32-byte shared key before creating the server and client configs:

```bash
openssl rand -hex 32
```

The room URL, shared key, provider, and transport must match on both sides. The recommended starting point is Jitsi with `datachannel`; choose a working host from the upstream [`jitsi.instances.yaml`](https://raw.githubusercontent.com/openlibrecommunity/olcrtc/refs/heads/master/docs/jitsi.instances.yaml) or [`found_jitsi_domains.txt`](https://raw.githubusercontent.com/denpiligrim/jitsi-scanner/refs/heads/main/found_jitsi_domains.txt).

- Server config at `./server/config.yaml`:
    ```yaml
    mode: srv
    auth:
      provider: jitsi
    room:
      id: "https://JITSI_HOST/ROOM"
    crypto:
      key: "REPLACE_WITH_64_HEX_CHAR_KEY"
    net:
      transport: datachannel
      dns: "8.8.8.8:53"
    ```

- Client config at `./client/config.yaml`:
    ```yaml
    mode: cnc
    auth:
      provider: jitsi
    room:
      id: "https://JITSI_HOST/ROOM"
    crypto:
      key: "REPLACE_WITH_64_HEX_CHAR_KEY"
    net:
      transport: datachannel
      dns: "8.8.8.8:53"
    socks:
      host: "0.0.0.0"
      port: 8808
      user: "olcrtc"
      pass: "CHANGE_ME"
    ```

## Run

The same image is used for both tunnel endpoints. Run the server on a host with unrestricted internet access and the client on the restricted network.

- Server:
    ```bash
    docker run --rm -it \
      -v ./server:/data:ro \
      ghcr.io/ergolyam/olcrtc-docker:latest
    ```

- Client:
    ```bash
    docker run --rm -it \
      -p 127.0.0.1:8808:8808/tcp \
      -v ./client:/data:ro \
      ghcr.io/ergolyam/olcrtc-docker:latest
    ```

Configure applications to use the SOCKS5 proxy at `127.0.0.1:8808` with the username and password from the client config.

When using a locally built image, replace `ghcr.io/ergolyam/olcrtc-docker:latest` with `olcrtc` in the run commands.

## Additional options

olcRTC also supports `telemost` and `wbstream` providers, `vp8channel`, `seichannel`, and `videochannel` transports, failover profiles, external key files, and an upstream SOCKS5 proxy on the server. See the upstream [configuration reference](https://github.com/openlibrecommunity/olcrtc/blob/master/docs/configuration.md) for the complete YAML schema and compatibility requirements.
