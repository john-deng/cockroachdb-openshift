#!/usr/bin/env bash
#
# Based on https://github.com/cockroachdb/cockroach/tree/master/cloud/kubernetes
#

set -exuo pipefail

# Clean up anything from a prior run:
oc delete petsets,pods,persistentvolumes,persistentvolumeclaims,services,poddisruptionbudget -l app=cockroachdb

for i in $(seq 0 2); do
  echo "
  sudo rm -rf /tmp/cockroachdb-${i}
  sudo mkdir -p /tmp/cockroachdb-${i}
  sudo chmod a+w /tmp/cockroachdb-${i}
  " | 
  cat <<EOF | oc replace --force -f -
kind: PersistentVolume
apiVersion: v1
metadata:
  name: cockroachdb-${i}
  labels:
    type: local
    app: cockroachdb
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/tmp/cockroachdb-${i}"
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: datadir-cockroachdb-${i}
  labels:
    app: cockroachdb
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF
done;

oc replace --force -f cockroachdb-statefulset.yaml
