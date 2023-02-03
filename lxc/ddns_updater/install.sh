#!/usr/bin/env bash

URL='https://github.com/qdm12/ddns-updater.git'
BRANCH='master'
TAG='latest'

apk update
apk add --no-cache git make musl-dev go g++ nano

mkdir -p /tmp/ddns-updater
git clone  $URL --depth=1 --single-branch --branch $BRANCH  /tmp/ddns-updater 
cd /tmp/ddns-updater
go mod download

# set go cache
export GOCACHE=/tmp/go-cache
rm -rf $GOCACHE
mkdir -p $GOCACHE
go env GOCACHE


VERSION="unknown"
BUILD_DATE=$(date +'%Y%m%d')
COMMIT=$(git rev-parse --short HEAD)

#use static go
# CGO_ENABLED=0 
go build -a -trimpath -ldflags="-extldflags '-static' -s -w \
    -X 'main.version=$VERSION' \
    -X 'main.buildDate=$BUILD_DATE' \
    -X 'main.commit=$COMMIT' \
    " -o /updater/app /tmp/ddns-updater/cmd/updater/main.go


rm -rf /tmp/ddns-updater &>/dev/null
mkdir -p /updater/data/ &>/dev/null
chmod +x /updater/app &>/dev/null

cat << 'EOF' > /updater/data/.env
#  CONFIG= 
#  PERIOD=5m 
#  UPDATE_COOLDOWN_PERIOD=5m 
#  PUBLICIP_FETCHERS=all 
#  PUBLICIP_HTTP_PROVIDERS=all 
#  PUBLICIPV4_HTTP_PROVIDERS=all 
#  PUBLICIPV6_HTTP_PROVIDERS=all 
#  PUBLICIP_DNS_PROVIDERS=all 
#  PUBLICIP_DNS_TIMEOUT=3s 
#  HTTP_TIMEOUT=10s 
DATADIR=/updater/data 
IPV6_PREFIX="/64"

#  # Web U
LISTENING_PORT=82
#  ROOT_URL=/ 

#  # Backu
#  BACKUP_PERIOD=0 
#  BACKUP_DIRECTORY=/updater/data 

#  # Othe
#  LOG_LEVEL=info 
#  LOG_CALLER=hidden 
#  SHOUTRRR_ADDRESSES= 
#  TZ
EOF

log "Creating ddns-updater service"
cat << 'EOF' > /etc/init.d/ddns-updater
#!/sbin/openrc-run
description="ddns-updater"

command="/updater/app"
command_args="2>&1 | tee -a /updater/data/ddns-updater.log"
command_background="true"
directory="/updater/data"

pidfile="/var/run/ddns-updater.pid"
output_log="/updater/data/ddns-updater.msg"
error_log="/updater/data/ddns-updater.err"

start_pre() {
  mkdir -p /updater/data
  [[ -f /updater/data/.env ]] && export $(sed 's/#.*//g' /updater/data/.env | xargs)
  env
}

stop() {
  pkill -9 -f app
  return 0
}

restart() {
  $0 stop
  $0 start
}
EOF

go clean -cache
rc-service ddns-updater stop &>/dev/null
chmod a+x /etc/init.d/ddns-updater
sleep 3
rc-update add ddns-updater boot &>/dev/null
rc-service ddns-updater start &>/dev/null
