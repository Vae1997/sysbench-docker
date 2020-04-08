FROM ubuntu:16.04
COPY sysbench.tar.gz /tmp/
COPY sources.list /etc/apt/
RUN apt-get update \
 && apt-get install -y --allow-unauthenticated make automake libtool pkg-config libaio-dev \
 && tar -xf /tmp/sysbench.tar.gz -C /root/ \
 && cd /root/sysbench/ && ./autogen.sh && ./configure --without-mysql && make -j && make install \
 && apt-get purge -y --auto-remove make automake pkg-config libtool \
 && rm -rf /var/lib/apt/lists/* \
 && rm /tmp/sysbench.tar.gz && cd /root/ && rm -rf sysbench/
