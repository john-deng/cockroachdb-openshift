# Install Cockroachdb on Openshift

## 1. Create a new project on openshift

```
oc new-project demo
```

## 2. Edit project UID and GID

```
oc edit ns demo
```

then change uid-range and groups to 0

``
    openshift.io/sa.scc.supplemental-groups: 0/10000
    openshift.io/sa.scc.uid-range: 0/10000
``

## 3. Create PV,PVC
### 3.1 Mount PV on host path (for demo only)

```
./cockroach-pvc.sh
```
### 3.2 Mount PV on glusterfs ( assume that you've installed glusterfs and heketi on openshift, then use [hi-cli](https://github.com/hi-cli/hi-cli) and [hi-heketi](https://github.com/hi-cli/hi-heketi) ) to create PV and PVC

```
for i in $(seq 0 2); do
    hi heketi create pv size=4 pvc name=datadir-cockroachdb-$i uid=0
done;
```

## 4. Deploy Cockroachdb statefulset

```
oc create -f cockroachdb-statefulset.yaml
```

## 5. Expose service

```
oc expose svc/cockroachdb-public --port=8080
```

## 6. Done, let's check if it works.

```
oc get ep,all                                                                                                                                14:28:16  2017-05-18
NAME                          ENDPOINTS                                                            AGE
ep/cockroachdb                10.128.2.98:26257,10.129.1.13:26257,10.130.0.220:26257 + 3 more...   31m
ep/cockroachdb-public         10.128.2.98:26257,10.129.1.13:26257,10.130.0.220:26257 + 3 more...   31m
ep/heketi-storage-endpoints   192.168.1.91:1,192.168.1.92:1,192.168.1.93:1                         28m

NAME                        HOST/PORT                                    PATH      SERVICES             PORT      TERMINATION
routes/cockroachdb-public   cockroachdb-public-demo.172.16.5.95.nip.io             cockroachdb-public   http

NAME                     CLUSTER-IP       EXTERNAL-IP   PORT(S)              AGE
svc/cockroachdb          None             <none>        26257/TCP,8080/TCP   31m
svc/cockroachdb-public   172.30.163.153   <none>        26257/TCP,8080/TCP   31m
svc/glusterfs-cluster    172.30.45.131    <none>        1/TCP                28m

NAME               READY     STATUS    RESTARTS   AGE
po/cockroachdb-0   1/1       Running   0          31m
po/cockroachdb-1   1/1       Running   0          27m
po/cockroachdb-2   1/1       Running   0          25m
```
## 7. Screenshots

### 7.1 Cluster Overview

![](/assets/cockroachdb-cluster-overview.png)

### 7.1 Cluster Nodes

![](/assets/cockroachdb-cluster-nodes.png)

### 7.1 Cluster Databases

![](/assets/cockroachdb-cluster-databases.png)