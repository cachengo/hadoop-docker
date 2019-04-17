#!/bin/bash
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

/etc/init.d/ssh start

MAX_MEMORY_3=$((MAX_MEMORY / 3))
MAX_MEMORY_6=$((MAX_MEMORY / 6))

sed "s/{{NODE_MASTER}}/$NODE_MASTER/g" $HADOOP_HOME/tmpl/core-site.xml.tmpl > $HADOOP_HOME/etc/hadoop/core-site.xml
sed -i "s/{{NODE_MASTER_PORT}}/$NODE_MASTER_PORT/g" $HADOOP_HOME/etc/hadoop/core-site.xml

sed "s;{{HADOOP_HOME}};$HADOOP_HOME;g" $HADOOP_HOME/tmpl/hdfs-site.xml.tmpl > $HADOOP_HOME/etc/hadoop/hdfs-site.xml
sed -i "s/{{REPLICATION}}/$REPLICATION/g" $HADOOP_HOME/etc/hadoop/hdfs-site.xml

sed "s/{{MAX_MEMORY}}/$MAX_MEMORY/g" $HADOOP_HOME/tmpl/yarn-site.xml.tmpl > $HADOOP_HOME/etc/hadoop/yarn-site.xml
sed -i "s/{{NODE_MASTER}}/$NODE_MASTER/g" $HADOOP_HOME/etc/hadoop/yarn-site.xml

sed "s/{{MAX_MEMORY_3}}/$MAX_MEMORY_3/g" $HADOOP_HOME/tmpl/mapred-site.xml.tmpl > $HADOOP_HOME/etc/hadoop/mapred-site.xml
sed -i "s/{{MAX_MEMORY_6}}/$MAX_MEMORY_6/g" $HADOOP_HOME/etc/hadoop/mapred-site.xml

if [ "$NODE_ROLE" == 'master' ]; then

  touch $HADOOP_HOME/etc/hadoop/workers
  IFS=',' read -r -a array <<< "$WORKERS"
  for element in "${array[@]}"
  do
      echo "$element" >> $HADOOP_HOME/etc/hadoop/slaves
  done

  ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
  chmod 0600 ~/.ssh/authorized_keys

  echo 'Use the following public key when starting worker nodes:'
  cat ~/.ssh/id_rsa.pub

  # format namenode
  hdfs namenode -format

  # start hadoop
  start-dfs.sh
  start-yarn.sh
  mr-jobhistory-daemon.sh start historyserver

elif [ "$NODE_ROLE" == 'worker' ]; then
  echo $MASTER_PUB_KEY >> ~/.ssh/authorized_keys
  chmod 0600 ~/.ssh/authorized_keys
else
  echo "Role $NODE_ROLE not recognized. Exiting..."
  exit 1
fi

# keep container running
tail -f /dev/null
