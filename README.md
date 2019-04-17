# hadoop-docker
Docker builds of hadoop cluster components

## How to run

### Start a master node
```
docker run \
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

Coming soon: Adding worker nodes.

## Variables
- NODE_ROLE = "master" or "worker"
- MASTER_PUB_KEY = Value of the public key used by the master node
- NODE_MASTER = Location of the NameNode (usually part of master node)
- NODE_MASTER_PORT = Port on which the NameNode is exposed
- REPLICATION = Number of times data is replicated in the cluster. Don't enter a value higher than the actual number of worker nodes.
- MAX_MEMORY = How much memory (in Mb) can be allocated for YARN containers on a single node. This limit should be higher than all the others. However, it should not be the entire amount of RAM on the node.

## TODO
- Compile libhadoop from source to solve: `util.NativeCodeLoader: Unable to load native-hadoop library for your platform` in case it has performance implications.
