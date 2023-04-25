FROM ubuntu:focal

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils && \
    apt-get update && apt-get -y --no-install-recommends dist-upgrade && \
    apt-get install -y --no-install-recommends curl apt-transport-https ca-certificates && \
    apt-get install -y --no-install-recommends openjdk-8-jdk-headless locales logrotate sudo && \
    rm -rf /var/lib/apt/lists/* /tmp/*

RUN curl -O https://files.tiot.jp/riak/kv/3.2/3.2.0/ubuntu/focal64/riak_3.2.0-OTP22_amd64.deb && \
    dpkg -i riak_3.2.0-OTP22_amd64.deb && \
    rm -f riak_3.2.0-OTP22_amd64.deb

ENV DEBIAN_FRONTEND teletype \
    TERM=xterm \
    LANG en_US.UTF-8

ADD riak-kv-docker.sh /usr/bin/riak-docker

RUN chmod +x /usr/bin/riak-docker && \
    locale-gen en_US en_US.UTF-8 && \
    echo "ulimit -n 200000" >> /etc/default/riak && \
    echo "riak soft nofile 65536" >> /etc/security/limits.conf && \
    echo "riak hard nofile 200000" >> /etc/security/limits.conf && \
    echo "buckets.default.allow_mult = true" >> /etc/riak/riak.conf && \
    echo "log.syslog.level = warning" >> /etc/riak/riak.conf && \
    sed -i 's/127.0.0.1/0.0.0.0/' /etc/riak/advanced.config && \
    sed -i 's/listener.http.internal = 127.0.0.1/listener.http.internal = 0.0.0.0/' /etc/riak/riak.conf && \
    sed -i 's/listener.protobuf.internal = 127.0.0.1/listener.protobuf.internal = 0.0.0.0/' /etc/riak/riak.conf && \
    sed -i 's/search = off/search = on/' /etc/riak/riak.conf && \
    sed -i 's/storage_backend = bitcask/storage_backend = leveled/' /etc/riak/riak.conf && \
    sed -i 's/leveldb.maximum_memory.percent = 70/leveldb.maximum_memory.percent = 10/' /etc/riak/riak.conf && \
    sed -i 's/## ring_size = 64/ring_size = 64/' /etc/riak/riak.conf && \
    sed -i 's/search.solr.jvm_options = -Xms1g -Xmx1g/search.solr.jvm_options = -Xms4g -Xmx4g/' /etc/riak/riak.conf && \
    sed -i 's/log.console = file/log.console = console/' /etc/riak/riak.conf && \
    sed -i '/log.syslog = off/alog.syslog.ident = riak-kv' /etc/riak/riak.conf && \
    sed -i 's/log.syslog = off/log.syslog = on/' /etc/riak/riak.conf && \
    sed -i 's/log.console = file/log.console = off/' /etc/riak/riak.conf && \
    sed -i 's/leveled.compaction_top_hour = 23/leveled.compaction_top_hour = 6/' /etc/riak/riak.conf && \
    sed -i 's/mdc.cluster_manager = 127.0.0.1:9080/mdc.cluster_manager = 0.0.0.0:9080/' /etc/riak/riak.conf && \
    sed -i 's/leveled.log_level = info/leveled.log_level = warning/' /etc/riak/riak.conf && \
    sed -i 's/log.console.level = info/log.console.level = warning/' /etc/riak/riak.conf && \
    sed -i "/search = on/asearch.anti_entropy.throttle.tier1.solrq_queue_length = 0\n\
  search.anti_entropy.throttle.tier1.delay = 50ms\n\
  search.anti_entropy.throttle.tier2.solrq_queue_length = 50\n\
  search.anti_entropy.throttle.tier2.delay = 500ms\n\
  search.anti_entropy.throttle.tier3.solrq_queue_length = 100\n\
  search.anti_entropy.throttle.tier3.delay = 5000ms\n\
  search.anti_entropy.throttle.tier4.solrq_queue_length = 250\n\
  search.anti_entropy.throttle.tier4.delay = 10000ms" /etc/riak/riak.conf && \
    sed -i 's/## search.queue.high_watermark.purge_strategy = purge_one/search.queue.high_watermark.purge_strategy = purge_one/' /etc/riak/riak.conf && \
    sed -i 's/## search.queue.high_watermark = 1000/search.queue.high_watermark = 1000/' /etc/riak/riak.conf && \
    sed -i 's/## search.queue.batch.minimum = 10/search.queue.batch.minimum = 100/' /etc/riak/riak.conf && \
    sed -i 's/## search.queue.batch.maximum = 500/search.queue.batch.maximum = 1000/' /etc/riak/riak.conf && \
    sed -i 's/## search.queue.batch.flush_interval = 500ms/search.queue.batch.flush_interval = 5000ms/' /etc/riak/riak.conf && \
    sed -i 's/## leveled_reload_recalc = enabled/leveled_reload_recalc = enabled/' /etc/riak/riak.conf

ADD mapping-FoldToASCII.txt /usr/lib/riak/lib/yokozuna-riak_kv-2.9.1+build.1543.ref1be8760/priv/conf/
ADD mapping-ISOLatin1Accent.txt /usr/lib/riak/lib/yokozuna-riak_kv-2.9.1+build.1543.ref1be8760/priv/conf/

VOLUME /var/lib/riak

EXPOSE 8087 8098 9080

ENTRYPOINT ["/usr/bin/riak-docker"]
CMD ["foreground"]
