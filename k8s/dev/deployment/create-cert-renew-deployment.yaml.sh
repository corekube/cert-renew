#!/bin/bash

cat > cert-renew-deployment.yaml << EOF
 apiVersion: extensions/v1beta1
 kind: Deployment
 metadata:
   name: cert-renew-deployment
 spec:
   replicas: 1
   selector:
     matchLabels:
      app: cert-renew
      env: dev
   template:
     metadata:
       labels:
         app: cert-renew
         env: dev
         rev: "${BUILD_COMMIT}"
     spec:
       containers:
         - name: cert-renew
           image: ${DOCKER_REPO}:${IMAGE_TAG}
           volumeMounts:
             - name: cert-renew-config
               mountPath: /etc/config
             - name: cert-renew-nfs-pvc
               mountPath: /srv/
       volumes:
         - name: cert-renew-config
           configMap:
             name: cert-renew-config
         - name: cert-renew-nfs-pvc
           persistentVolumeClaim:
             claimName: cert-renew-nfs-pvc
EOF
