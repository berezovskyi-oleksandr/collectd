#!/bin/sh

sed -i 's,\(Hostname *"\).*\(".*\),\1'"${HOSTNAME}"'\2,' /etc/collectd/collectd.conf
collectd -f

