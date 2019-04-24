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

RUN apt-get update \
    && apt-get install -y openssh-server \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /root/

ENV VERSION=2.8.5

RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-$VERSION/hadoop-$VERSION.tar.gz \
    && tar -xzf hadoop-$VERSION.tar.gz \
    && mv hadoop-$VERSION ~/hadoop \
    && rm hadoop-$VERSION.tar.gz \
    && sed -i 's;${JAVA_HOME};'"$JAVA_HOME;g" ~/hadoop/etc/hadoop/hadoop-env.sh

COPY ssh_config .ssh/config

RUN mkdir -p ~/.ssh \
    && touch ~/.ssh/authorized_keys \
    && chmod 0600 ~/.ssh/authorized_keys

ENV HADOOP_HOME=/root/hadoop
ENV PATH="${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${PATH}"
WORKDIR $HADOOP_HOME

COPY *.tmpl ./tmpl/
COPY *.sh ./

RUN chmod +x ./*.sh

ENV NODE_ROLE=master
ENV NODE_MASTER=node-master
ENV NODE_MASTER_PORT=9000
ENV REPLICATION=1
ENV MAX_MEMORY=3072

EXPOSE 9000
EXPOSE 8088
EXPOSE 22

CMD bash ./start-hadoop.sh
