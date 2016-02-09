# cert-renew

A docker image suitable for requesting new certifcates from letsencrypt,
and storing them in a secret on kubernetes.

This is a fork of [ployst/docker](https://github.com/ployst/docker/tree/master/letsencrypt)
that does not use nginx, and therefore, does not directly serve the ACME requests for letsencrypt. Rather,
it lets a server container, one that is serving the Domain via nginx, to handle the ACME request while leveraging a volume mounted at /etc/letsencrypt that contains all the relevent cert data.
cert-renew also mounts this same volume as the server container at /etc/letsencrypt and uses it to perform the cert renewal steps and k8s Secret generation.

Decoupling the container serving the Domain from the cert-renew container issuing the
renewals allows for the clear separation of responsibilities, and allows for the creation & usage of a shared, housing volume for the letsencrypt data.

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
