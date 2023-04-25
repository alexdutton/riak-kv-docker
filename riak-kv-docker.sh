#!/bin/sh

NODENAME=$(hostname)
IP=$(hostname -I | tr " " "\n" | grep 192.168)
IP=${IP:=127.0.0.1}

sed -i "s/nodename = riak@127.0.0.1/nodename = riak@$NODENAME/" /etc/riak/riak.conf
sed -i "s/mdc.cluster_manager = 0.0.0.0:9080/mdc.cluster_manager = $IP:9080/" /etc/riak/riak.conf
sed -i "s/\"0.0.0.0\", 9080/\"$IP\", 9080/" /etc/riak/advanced.config

exec riak $@
