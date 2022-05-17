#!/bin/bash
set -eu
set -o pipefail

if [ $# -ne 1 ]; then
    echo "Invalid argument count." 1>&2
    exit 1
fi

# 使える文字は英数字とアンダーバー(多分他にも使えるが検証していない)
if [[ $1 =~ ^\w+$ ]]; then
    echo "Invalid character." 1>&2
    exit 1
fi

# 証明書生成
set +e
EASYRSA_REQ_CN=$1 EASYRSA_CERT_EXPIRE=3650 /usr/share/easy-rsa/easyrsa --batch build-client-full $1 nopass
set -e

echo "
##########################################
##### OpenVPN client config template #####
##########################################
# https://openvpn.net/community-resources/reference-manual-for-openvpn-2-4/
# CertName: $1

client
proto ${OPENVPN_PROTO/"server"/"client"}
dev tun
remote <<Hostname or IPAddress>> $OPENVPN_PORT
cipher AES-256-GCM
key-direction 1
redirect-gateway
# redirect-private
dhcp-option DNS 8.8.8.8

<ca>
`cat /openvpn/pki/ca.crt`
</ca>
<cert>
`openssl x509 -in /openvpn/pki/issued/$1.crt`
</cert>
<key>
`cat /openvpn/pki/private/$1.key`
</key>
<tls-auth>
`cat /openvpn/ta.key`
</tls-auth>
"
