FROM debian:jessie
MAINTAINER Mike Metral "metral@gmail.com"

RUN apt-get update \
    && apt-get install -y \
                        curl \
                        wget \
                        openssh-client \
                        cron \
                        bc \
    && rm -rf /var/lib/apt/lists/*

# setup letsencrypt bot
RUN wget https://dl.eff.org/certbot-auto
RUN chmod a+x ./certbot-auto
RUN echo "y" | DEBIAN_FRONTEND=noninteractive ./certbot-auto; exit 0
RUN ln -s /root/.local/share/cert-bot/bin/cert-bot /usr/local/bin/cert-bot
RUN rm -rf /etc/letsencrypt
WORKDIR /cert-renew

CMD ["/bin/bash"]
