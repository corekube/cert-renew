#!/bin/bash

cat > cert-renew-rc.yaml << EOF
 apiVersion: v1
 kind: ReplicationController
 metadata:
   name: cert-renew-rc
   labels:
     name: cert-renew-rc
   namespace: dev
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
           env:
             - name: DOMAINS
               value: ${DOMAINS}
             - name: EMAIL
               value: ${EMAIL}
             - name: RC_NAMES
               value: ${RC_NAMES}
             - name: SECRET_NAME
               value: ${SECRET_NAME}
             - name: LETSENCRYPT_ENDPOINT
               value: ${LETSENCRYPT_ENDPOINT}
           volumeMounts:
             - name: cert-renew-letsencrypt-pvc
               mountPath: /etc/letsencrypt
               readOnly: false
       imagePullSecrets:
         - name: cert-renew-registry-secret
       volumes:
         - name: cert-renew-letsencrypt-pvc
           persistentVolumeClaim:
             claimName: cert-renew-letsencrypt-pvc
EOF
