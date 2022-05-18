#!/bin/bash
set -eu
set -o pipefail

# CAの初期化
if [ ! -f /openvpn/ta.key ]; then
    /usr/share/easy-rsa/easyrsa init-pki
    EASYRSA_REQ_CN="Easy-RSA CA" EASYRSA_CA_EXPIRE=36500 /usr/share/easy-rsa/easyrsa --batch build-ca nopass
    EASYRSA_REQ_CN="OpenVPN Server" EASYRSA_CERT_EXPIRE=3650 /usr/share/easy-rsa/easyrsa --batch build-server-full openvpn-server nopass

    /usr/share/easy-rsa/easyrsa gen-dh
    openvpn --genkey secret /openvpn/ta.key
fi

# tunからの通信をNAPT
nft add table nat
nft add chain nat postrouting { type nat hook postrouting priority 100 \; }
nft add rule nat postrouting ip saddr ${OPENVPN_TUN_ADDRESS:-10.8.0.0}/24 masquerade

# OpenVPN起動
openvpn \
    --mode server \
    --proto ${OPENVPN_PROTO:-udp4} \
    --port ${OPENVPN_PORT:-1194} \
    --dev tun \
    --topology subnet \
    --server ${OPENVPN_TUN_ADDRESS:-10.8.0.0} 255.255.255.0 \
    --ca /openvpn/pki/ca.crt \
    --cert /openvpn/pki/issued/openvpn-server.crt \
    --key /openvpn/pki/private/openvpn-server.key \
    --dh /openvpn/pki/dh.pem \
    --tls-auth /openvpn/ta.key 0 \
    --keepalive 10 120 \
    --cipher AES-256-GCM \
    --log-append /dev/stdout \
    --verb 3 \
    --mute 20
