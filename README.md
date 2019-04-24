# hadoop-docker
Arm64 compatible builds of Hadoop. This image is compatible with the stable/hadoop Helm chart.

## How to run
1. Get a running version of Kubernetes with Helm installed
2. Start a Hadoop cluster:
```
helm install --name hadoop \
  --set image.repository=cachengo/hadoop \
  --set image.tag=latest \
  --set hdfs.dataNode.replicas=2 \
  --set image.pullPolicy=Always \
  stable/hadoop
```
3. Wait for containers to be ready: `kubectl get pods`
4. Check the status of HDFS:
```
kubectl exec -n default -it hadoop-hadoop-hdfs-nn-0 -- \
    /usr/local/hadoop/bin/hdfs dfsadmin -report
```
5. Create a port-forward to the yarn resource manager UI:
   `kubectl port-forward -n default hadoop-hadoop-yarn-rm-0 8088:8088`
6. Bring it all down: `helm delete --purge hadoop`
7. For more options checkout the official Hadoop Helm chart: https://github.com/helm/charts/tree/master/stable/hadoop

### Benchmark the cluster
1. You can run included hadoop tests like this:
```
 kubectl exec -n default -it hadoop-hadoop-yarn-nm-0 -- \
   /usr/local/hadoop/bin/hadoop \
   jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-2.8.5-tests.jar \
   TestDFSIO \
   -write \
   -nrFiles 5 \
   -fileSize 128MB \
   -resFile /tmp/TestDFSIOwrite.txt
```

## TODO
- Compile libhadoop from source to solve: `util.NativeCodeLoader: Unable to load native-hadoop library for your platform` in case it has performance implications.
