FROM docker.io/library/debian:bullseye-slim

COPY scripts/start-openvpn.sh scripts/generate-client.sh /usr/local/bin/
RUN apt update && apt install --yes openvpn nftables && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    chmod +x /usr/local/bin/start-openvpn.sh /usr/local/bin/generate-client.sh

WORKDIR /openvpn

CMD ["/usr/local/bin/start-openvpn.sh"]
