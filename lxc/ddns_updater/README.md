
# [ddns_updater](https://github.com/qdm12/ddns-updater)

## To Install

``` bash
    wget --no-cache -qO - https://raw.githubusercontent.com/hereisderek/proxmox-scripts/main/lxc/ddns_updater/install.sh | sh
```

## To config
mount `/updater/data` or directly modify the `/updater/data/.env` file in the container

By default, the content is as follows:

```
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
```

## Logs
In container, execute: 

```
tail -f -n 300 /updater/data/ddns-updater.log
```

## To restart service

In container, execute:

```bash
rc-service ddns-updater restart
```