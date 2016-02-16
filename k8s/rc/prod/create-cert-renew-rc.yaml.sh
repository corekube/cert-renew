#!/bin/bash

cat > cert-renew-rc.yaml << EOF
 apiVersion: v1
 kind: ReplicationController
 metadata:
   name: cert-renew-rc
   labels:
     name: cert-renew-rc
   namespace: cert-renew-prod
 spec:
   replicas: 1
   selector:
     name: cert-renew
     deployment: ${WERCKER_GIT_COMMIT}
   template:
     metadata:
       labels:
         name: cert-renew
         deployment: ${WERCKER_GIT_COMMIT}
     spec:
       containers:
         - name: cert-renew
           image: ${DOCKER_REPO}:${WERCKER_GIT_COMMIT}
           volumeMounts:
             - name: cert-renew-config-secret
               mountPath: /etc/cert-renew-config-secret
               readOnly: true
             - name: cert-renew-nfs-pvc
               mountPath: /srv/
               readOnly: false
       volumes:
         - name: cert-renew-config-secret
           secret:
             secretName: cert-renew-config-secret
         - name: cert-renew-nfs-pvc
           persistentVolumeClaim:
             claimName: cert-renew-nfs-pvc
EOF
