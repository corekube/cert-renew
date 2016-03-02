# cert-renew

A Docker image that is deployed on Kubernetes to auto-renew the [letsencrypt.org](https://letsencrypt.org) SSL/TLS certificates via cron, and perform a rolling-update to the ReplicationController(s) or Deployment(s) depending on them.

This is a fork of [ployst/docker](https://github.com/ployst/docker/tree/master/letsencrypt)
that does not use nginx, and therefore, does not directly handle the ACME requests sent by [letsencrypt.org](https://letsencrypt.org) on renawals.

Rather, it lets a webserver container, the one that is actually serving content on behalf of the Domain, such as [corekube/nginx](https://github.com/corekube/nginx), to handle the ACME request so that this container is only concerned with renewing the certs and propogating any changes across the Kubernetes cluster resources that use them.

This Docker image renews the certs automatically, given that:

1. Configuration settings to be used with the letsencrypt tool are provided via a Kubernetes Secret named `cert-renew-config-secret`, defined as such as:

      ```
       apiVersion: v1
       kind: Secret
       metadata:
         name: cert-renew-config-secret
         namespace: cert-renew-<NAMESPACE>
       type: Opaque
       data:
         env: <CONFIG_BASE64>
      ```
      where the embedded config data is similar to:
      
      ```
      export DOMAINS='example.com www.example.com'
      export EMAIL=joe@example.com
      export RC_NAMES=foobar-rc OR export DEPLOYMENT_NAMES=foobar-deployment
      export SECRET_NAME=foobar-ssl-secret
      export NAMESPACE=cert-renew-<NAMESPACE>
      ```
2. Like [corekube/nginx](https://github.com/corekube/nginx), it also needs access to the same pre-existing [letsencrypt.org](https://letsencrypt.org)
`/etc/letsencrypt` directory to be mounted as a volume in `/srv` as `/srv/etc/letsencrypt` and uses it to perform:

   1. The actual cert renewal steps as defined by [letsencrypt.org](https://letsencrypt.org)
      * Handled by `fetch_certs.sh` 
   2. Generation & updating of the Kubernetes Secret that the webserver container uses - in [corekube/nginx](https://github.com/corekube/nginx), this is the `nginx-ssl-secret` used.
      * Handled by `save_certs.sh` 
   3. A `rolling-update` of the Kubernetes resource, which can be either a ReplicationController or a Deployment, that the
      webserver container uses - in [corekube/nginx](https://github.com/corekube/nginx), this is `nginx-deployment`.
      * Handled by `recreate_pods.sh`

**Note:** In facilitation of the overall process, `refresh_certs.sh` is an aggregate of the previously mentioned scripts.

The real driver behind cert-renew is the decoupling of the webserver container from requesting the cert renewals and rather have it focus on serving content, which not only allows for the clear separation of responsibilities, but for the creation & usage of a shared, housing volume for the letsencrypt data between the cert-renew & [corekube/nginx](https://github.com/corekube/nginx) Pods.

## Useful [manual] commands

### Generate a new set of certs

Once this container is running you can generate new certificates using:

```
kubectl exec -it <POD> -- /bin/bash -c "EMAIL=joe@example.com DOMAINS='example.com foo.example.com' ./fetch_certs.sh"
```

### Save the set of certificates as a K8s Secret

```
kubectl exec -it <POD> -- /bin/bash -c "EMAIL=joe@example.com DOMAINS='example.com foo.example.com' RC_NAMES=foobar-rc SECRET_NAME=foobar-ssl-secret ./save_certs.sh"
```

### Perform a rolling-upgrade on the ReplicationController utilizing the K8s Secret

```
kubectl exec -it <POD> -- /bin/bash -c "RC_NAMES=foobar-rc NAMESPACE=default ./recreate_pods.sh"
```

## Environment variables:

 - DOMAINS - a space separated list of domains to obtain a certificate for.
  - i.e. DOMAINS='example.com www.example.com'
 - EMAIL - the email address to obtain certificates on behalf of.
  - i.e. EMAIL=joe@example.com
 - LETSENCRYPT_ENDPOINT
   - If set, will be used to populate the /etc/letsencrypt/cli.ini file with
     the given server value. For testing use
     https://acme-staging.api.letsencrypt.org/directory
 - RC_NAMES - a space separated list of ReplicationController's whose pods to perform a rolling-update on after a
   certificate save. **Note:** This can not currently be used in conjuction with `DEPLOYMENT_NAMES`
 - DEPLOYMENT_NAMES - a space separated list of Deployment's whose pods to perform a rolling-update on after a
   certificate save. **Note:** This can not currently be used in conjuction with `RC_NAMES`
  - i.e. RC_NAMES=foobar-rc
 - SECRET_NAME - the name to save the secrets under in the current namespace
  - i.e. SECRET_NAME=foobar-ssl-secret
 - NAMESPACE - the name of the namespace where the `RC_NAMES` or `DEPLOYMENT_NAMES` exist
  - i.e. NAMESPACE=default
 - CRON_FREQUENCY - the 5-part frequency of the cron job. Default is a random
   time in the range `0-59 0-23 1-27 * *`. Can also be set to `none` to disable an entry from being added into the crontab
