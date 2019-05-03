# Copyright 2019, Cachengo, Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM openjdk:8-stretch

WORKDIR /usr/local

ENV VERSION=2.8.5

RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-$VERSION/hadoop-$VERSION.tar.gz \
    && tar -xzf hadoop-$VERSION.tar.gz \
    && mv hadoop-$VERSION ./hadoop \
    && rm hadoop-$VERSION.tar.gz \
    && sed -i 's;${JAVA_HOME};'"$JAVA_HOME;g" ./hadoop/etc/hadoop/hadoop-env.sh

ENV HADOOP_PREFIX=/usr/local/hadoop \
    HADOOP_COMMON_HOME=/usr/local/hadoop \
    HADOOP_HDFS_HOME=/usr/local/hadoop \
    HADOOP_MAPRED_HOME=/usr/local/hadoop \
    HADOOP_YARN_HOME=/usr/local/hadoop \
    HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop \
    YARN_CONF_DIR=/usr/local/hadoop/etc/hadoop \
    PATH=${PATH}:/usr/local/hadoop/bin:/usr/local/hadoop/sbin

COPY protobuf-2.5.0-arm64.patch /protobuf-2.5.0-arm64.patch

RUN apt-get update \
    && apt-get install -y --no-install-recommends autoconf automake libtool curl make g++ unzip patch cmake zlib1g zlib1g-dev libsnappy-dev maven pkgconf libssl1.0-dev libbz2-dev \
    && cd / \
    && export PROTOC_VERSION=2.5.0 \
    && git clone https://github.com/google/protobuf.git \
    && cd protobuf \
    && git checkout v$PROTOC_VERSION \
    && patch -p1 < /protobuf-2.5.0-arm64.patch \
    && curl $curlopts -L -O https://github.com/google/googletest/archive/release-1.7.0.zip \
    && unzip -q release-1.7.0.zip \
    && rm release-1.7.0.zip \
    && mv googletest-release-1.7.0 gtest \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install \
    && export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH \
    && echo /usr/local/lib >> /etc/ld.so.conf \
    && ldconfig \
    && rm -rf /protobuf \
    && rm -rf /var/lib/apt/lists/*

RUN cd / \
    && git clone https://github.com/apache/hadoop.git \
    && cd hadoop \
    && git checkout branch-$VERSION \
    && mvn package -Pdist,native -DskipTests -Dtar -X \
    && mkdir -p $HADOOP_PREFIX/lib/native \
    && cp -r hadoop-dist/target/hadoop-$VERSION/lib/native/* $HADOOP_PREFIX/lib/native \
    && cd .. \
    && rm -rf /hadoop

ENV HADOOP_OPTS="$HADOOP_OPTS -Djava.library.path=$HADOOP_PREFIX/lib/native"

WORKDIR $HADOOP_PREFIX

# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000
# Mapred ports
EXPOSE 19888
#Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088
#Other ports
EXPOSE 49707 2122
