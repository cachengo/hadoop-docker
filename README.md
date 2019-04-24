# hadoop-docker
Docker builds of hadoop cluster components

## How to run

### Start a cluster on one computer
1. Start a docker network: `docker network create hadoop`
2. Start the master
```
docker run -d \
  --net=hadoop \
  --name=node-master \
  -e NODE_MASTER=node-master \
  -e NODE_MASTER_PORT=9000 \
  -e NODE_ROLE=master \
  -e REPLICATION=1 \
  -p 9000:9000 \
  -p 8088:8088 \
  cachengo/hadoop;
```
3. Get the master public key: `docker exec node-master ./get-pubkey.sh`
4. Start the worker:
```
docker run -d \
  --net=hadoop \
  --name=worker1 \
  -e NODE_MASTER=node-master \
  -e NODE_MASTER_PORT=9000 \
  -e NODE_ROLE=worker \
  -e REPLICATION=1 \
  -e MASTER_PUB_KEY='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCfUCFWvFGBey1YlstNsQLzeipMoGUdRebGYxcJ3XkSQNzBug8vy/6s4RvWT9ubGSX8cqs2mvaCxmVYClkjSoqR8RvfqitWNXifWm7KsDzTTeso1Yczx4kFFOEbya8rjqJiNOjDLEh3mRI7DHOkjdwz69eEpJhjYsNAPV5apP94YR0brpdt9ClFoOs4h9VwfNIH7e7fKVtgE/xy6jsbsoF3tu2+gdO4AUimGFRBtl8/cx3yj+b8hXmc9Gsr7JY204sqAFu8cO2oHej/QHGnbVktuHe0l6FpxfqIq6g44xVnQnkk+dLJGVR+5on8eqDIcCm24Y60WO3PLIAMSPrrnGyr root@e3db4d49e6f8' \
  cachengo/hadoop;
```
5. Tell the master node to use the new worker: `docker exec node-master ./add-worker.sh -h worker1`

For additional nodes repeat steps 3 and 4

### Start a cluster across multiple devices
1. Get a running Kubernetes cluster
2. Start the master: `kubectl create -f master-service.yaml`
3. Start the worker:
```
MASTER_POD=`kubectl get pods | grep node-master | cut -d " " -f1`
MASTER_PUB_KEY=`kubectl exec $MASTER_POD ./get-pubkey.sh`
sed "s;{{MASTER_PUB_KEY}};$MASTER_PUB_KEY;g" worker-service.yaml > worker-service.yaml.tmp
kubectl create -f worker-service.yaml.tmp
rm worker-service.yaml.tmp
```
4. Tell the master node to use the new worker: `kubectl exec $MASTER_POD -- ./add-worker.sh -h node-worker1`
5. Check cluster status: `kubectl exec $MASTER_POD -- hdfs dfsadmin -report`

## Variables
- NODE_ROLE = "master" or "worker"
- MASTER_PUB_KEY = Value of the public key used by the master node
- NODE_MASTER = Location of the NameNode (usually part of master node)
- NODE_MASTER_PORT = Port on which the NameNode is exposed
- REPLICATION = Number of times data is replicated in the cluster. Don't enter a value higher than the actual number of worker nodes.
- MAX_MEMORY = How much memory (in Mb) can be allocated for YARN containers on a single node. This limit should be higher than all the others. However, it should not be the entire amount of RAM on the node.
- SSH_PORT = Port on which to expose the SSH server

## TODO
- Compile libhadoop from source to solve: `util.NativeCodeLoader: Unable to load native-hadoop library for your platform` in case it has performance implications.
