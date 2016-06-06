# cert-renew

A Docker image that is deployed on Kubernetes to auto-renew the [letsencrypt.org](https://letsencrypt.org) SSL/TLS certificates stored in a mounted volume, via Cron.

This project began as a fork of [ployst/docker](https://github.com/ployst/docker/tree/master/letsencrypt)
that does not use nginx, and therefore, does not directly handle the ACME requests sent by [letsencrypt.org](https://letsencrypt.org) on renewals. Rather, it relies on a separate webserver to handle the LetsEncrypt ACME request so that this microservice is solely focused on renewing the certs.

For cert-renew to work, you must provide the following:

- The configuration settings for the LetsEncrypt cert-bot tool, provided in a Kubernetes ConfigMap named `cert-renew-config`, defined as such as:

      ```
       apiVersion: v1
       kind: ConfigMap
       metadata:
         name: cert-renew-config
       cert-renew: |
         #!/bin/bash
         
         export DOMAINS='example.com www.example.com'
         export EMAIL=joe@example.com
         export CRON_FREQUENCY="0 0 1 * *"
         export LETSENCRYPT_DIR="/srv/etc/letsencrypt"
         export LETSENCRYPT_ENDPOINT="https://acme-staging.api.letsencrypt.org/directory"
       
      ```
      
      Config Options:
      
            - DOMAINS - a space separated list of domains to obtain a certificate for, enclosed in single quotes
                - i.e. DOMAINS='example.com www.example.com'
            - EMAIL - the email address to obtain certificates on behalf of.
                - i.e. EMAIL=joe@example.com
            - CRON_FREQUENCY - optional - the 5-part frequency schedule of the cron job. Default is a random
               time in the range `0-59 0-23 1-27 * *` if not specified.
                - i.e. "0 0 1 * *" will renew the certs at midnight on the 1st of every month
            - LETSENCRYPT_DIR - The path of the mounted volume holding your LetsEncrypt certs. You must supply the full /etc/letsencrypt directory created by LetsEncrypt upon initial cert generation. This project does not handle the initialization of your certs, only their renewal. 
            - LETSENCRYPT_ENDPOINT - endpoint used to communicate with LetsEncrypt
                - i.e. testing endpoint: https://acme-staging.api.letsencrypt.org/directory
                - i.e. live endpoint: https://acme-v01.api.letsencrypt.org/directory

## Useful commands

### Manually renew the certs

Once this container is running you can generate new certificates using:

```
kubectl exec -it <POD> -- /bin/bash -c "EMAIL=joe@example.com DOMAINS='example.com foo.example.com' LETSENCRYPT_DIR="/mycerts/etc/letsencrypt" LETSENCRYPT_ENDPOINT="https://acme-v01.api.letsencrypt.org/directory" ./fetch_certs.sh"
```


