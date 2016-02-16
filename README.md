# cert-renew

A docker image suitable for requesting new certifcates from letsencrypt,
and storing them in a secret on Kubernetes.

This is a fork of [ployst/docker](https://github.com/ployst/docker/tree/master/letsencrypt)
that does not use nginx, and therefore, does not directly serve the ACME requests for letsencrypt on renawals. Rather,
it lets a server container, the one that is actually serving on behalf of the Domain such as [corekube/nginx](https://github.com/corekube/nginx), to handle the ACME request.

Upon cert renewal, letsencrypt.org will send an ACME request to server container to handle it - in [corekube/nginx](https://github.com/corekube/nginx), it handles this request using a [pre-existing letsencrypt](https://getcarina.com/docs/tutorials/nginx-with-lets-encrypt/) `/etc/letsencrypt` initialized volume [mounted at /srv](https://github.com/corekube/nginx/blob/master/nginx/proxy_ssl.conf#L55).

This project, cert-renew, also mounts this same pre-existing
`/etc/letsencrypt` volume at /srv and uses it to perform:

1. The cert renewal steps
2. Generation & updating of the K8s Secret that the server container uses - in [corekube/nginx](https://github.com/corekube/nginx), this is the `nginx-ssl-secret` used.
3. Performing a rolling upgrade of the K8s ReplicationController that the
   server container uses - in [corekube/nginx](https://github.com/corekube/nginx), this is the `nginx-rc` used.
4. Saving the newly updated K8s Secret for the server container in a designated outpath path that the nginx Pod utilizes.

Decoupling the container serving the Domain from the cert-renew container issuing the
renewals, allows for the clear separation of responsibilities, and for the creation & usage of a shared, housing volume for the letsencrypt data between the cert-renew & [corekube/nginx](https://github.com/corekube/nginx) Pods.

## Purpose

To provide an application that owns certificate requesting and storing.

 - To regularly (monthly) ask for new certificates.
 - To store those new certificates in a secret on kubernetes.

## Useful commands

### Generate a new set of certs

Once this container is running you can generate new certificates using:

kubectl exec -it <container> /bin/bash -- -c 'EMAIL=fred@fred.com DOMAINS=example.com foo.example.com ./fetch_certs.sh'


### Save the set of certificates as a secret

kubectl exec -it <container> /bin/bash -- -c 'DOMAINS=example.com foo.example.com ./save_certs.sh'


## Environment variables:

 - EMAIL - the email address to obtain certificates on behalf of.
 - DOMAINS - a space separated list of domains to obtain a certificate for.
 - LETSENCRYPT_ENDPOINT
   - If set, will be used to populate the /etc/letsencrypt/cli.ini file with
     the given server value. For testing use
     https://acme-staging.api.letsencrypt.org/directory
 - RC_NAMES - a space separated list of RC's whose pods to destroy after a
   certificate save.
 - SECRET_NAME - the name to save the secrets under
 - CRON_FREQUENCY - the 5-part frequency of the cron job. Default is a random
   time in the range `0-59 0-23 1-27 * *`
