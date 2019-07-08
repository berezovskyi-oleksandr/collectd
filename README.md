# Docker Image for Collectd for IoT

Supports only MQTT

To be used with InfluxDB and Grafana, e.g. standalone:

```bash
docker run -d \
           --name influxdb \
           -e INFLUXDB_COLLECTD_ENABLED=true \
           -e INFLUXDB_COLLECTD_DATABASE=_internal \
           -e INFLUXDB_COLLECTD_TYPESDB=/usr/share/collectd/types.db \
           -e INFLUXDB_COLLECTD_SECURITY_LEVEL=none \
           -v /usr/share/collectd/types.db:/usr/share/collectd/types.db \
           influxdb
docker run -d \
           --name=grafana \
           -p 3000:3000 \
           -e "GF_SECURITY_ADMIN_PASSWORD=secret" \
           --link influxdb:influxdb grafana/grafana
docker run -d \
           --name collectd \
           --hostname ${HOSTNAME} \
           --link influxdb:influxdb \
           mwaeckerlin/collectd
```

or in docker swarm:

```yaml
version: '3.3'
services:

  grafana:
    image: grafana/grafana
    ports:
      - 3000:3000
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=secret

  influxdb:
    image: influxdb
    volumes:
      - type: 'bind'
        source: /srv/volumes/grafana-mrw-sh/influxdb
        target: /var/lib/influxdb
      - type: 'bind'
        source: /srv/volumes/grafana-mrw-sh/collectd/types.db
        target: /usr/share/collectd/types.db
    environment:
      - INFLUXDB_COLLECTD_ENABLED=true
      - INFLUXDB_COLLECTD_DATABASE=_internal
      - INFLUXDB_COLLECTD_TYPESDB=/usr/share/collectd/types.db
      - INFLUXDB_COLLECTD_SECURITY_LEVEL=none

  collectd-jupiter:
    image: mwaeckerlin/collectd
    hostname: jupiter
    deploy:
      placement:
        constraints:
          - node.hostname==jupiter

  collectd-dock01:
    image: mwaeckerlin/collectd
    hostname: dock01
    deploy:
      placement:
        constraints:
          - node.hostname==dock01

  collectd-dock02:
   image: mwaeckerlin/collectd
    hostname: dock02
    deploy:
      placement:
        constraints:
          - node.hostname==dock02

  collectd-dock03:
    image: mwaeckerlin/collectd
    hostname: dock03
    deploy:
      placement:
        constraints:
          - node.hostname==dock03

  collectd-dock04:
    image: mwaeckerlin/collectd
    hostname: dock04
    deploy:
      placement:
        constraints:
          - node.hostname==dock04

  collectd-dock05:
    image: mwaeckerlin/collectd
    hostname: dock05
    deploy:
      placement:
        constraints:
          - node.hostname==dock05

  collectd-dock06:
    image: mwaeckerlin/collectd
    hostname: dock06
    deploy:
      placement:
        constraints:
          - node.hostname==dock06
```

## Getting `types.db`

Make sure `/usr/share/collectd/types.db` exists. You can copy it from a `mwaeckerlin/collectd` container:

```bash
docker create --name temporary mwaeckerlin/collectd
docker cp temporary:/usr/share/collectd/types.db types.db
sudo mkdir -p /usr/share/collectd
sudo mv -i types.db /usr/share/collectd/
docker rm temporary
```

## Configure Grafana

 - Head your browser to the Grafana url, e.g. `http://localhost:3000`.
 - Login with user `admin` and your password, in the example above, that's `secret`.
 - Add data source:
    - Click `InfluxDB`
       - Set `Name`: `InfluxDB - Collectd` (or whatever you like)
       - Set `URL`: `http://influxdb:8086`
       - Set `Database`: `_internal`
       - Click `Save & Test`
 - Back to `Home Dashboard`, choose `New dashboard`:
    - Click `New dashboard`
    - Click `Import dashboard`
    - Paste `554` to `Grafana.com dashboard` (as an example)
       - Set `Name`: `Host Overview` (or whatever you like)
       - Click `change` on `Unique identifier (uid)`
       - Choose `InfluxDB - Collectd` in `influxdb_collectd`
       - Click `Import`
