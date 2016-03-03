FROM debian:jessie

RUN apt-get update && apt-get install -y git wget cron bc

RUN git clone https://github.com/letsencrypt/letsencrypt /letsencrypt/app
WORKDIR /letsencrypt/app
RUN git pull && git checkout -b v0.4.0 tags/v0.4.0
RUN ./letsencrypt-auto; exit 0

# Install kubectl
RUN wget https://2522efd282c835e41a50-53d2109cb9f8568d9672b747b92a2551.ssl.cf1.rackcdn.com/kubectl
RUN chmod +x kubectl
RUN mv kubectl /usr/local/bin/

RUN ln -s /root/.local/share/letsencrypt/bin/letsencrypt /usr/local/bin/letsencrypt
RUN rm -rf /etc/letsencrypt

WORKDIR /letsencrypt

CMD ["/letsencrypt/start.sh"]
