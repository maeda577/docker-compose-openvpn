# DockerでOpenVPNを作る

## これは何

OpenVPNのコンテナを作るDockerfileです。以下のような動作をします。

* 初回起動時にeasy-rsaでCA証明書とサーバー証明書を作成
* デフォルトでは1194/udpで待ち受けるOpenVPNを起動
* 都度スクリプト経由でクライアント用証明書とconfigサンプルを生成
    * configサンプルはOpenVPN Connectで使う前提です。他のクライアントでは設定が不足している可能性があります。

## インストール方法

docker-compose用ファイルを用意してあるため、それを実行してください。

``` shell
# 適当な作業フォルダを作成
mkdir ~/openvpn
cd ~/openvpn
# compose用ファイルをダウンロードして適宜編集
curl --output docker-compose.yml https://raw.githubusercontent.com/maeda577/docker-openvpn/main/docker-compose.yml

# コンテナ群の起動
docker-compose up --detach
# クライアント用証明書の生成とサンプルconfig表示
docker-compose exec openvpn generate-client.sh <任意のクライアント名(例: iphone)>
```
