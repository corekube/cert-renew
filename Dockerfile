FROM debian:jessie

RUN apt-get update && apt-get install -y git wget cron bc

RUN git clone https://github.com/letsencrypt/letsencrypt /letsencrypt/app
WORKDIR /letsencrypt/app
RUN ./letsencrypt-auto; exit 0

# Install kubectl
RUN wget https://storage.googleapis.com/kubernetes-release/release/v1.1.7/bin/linux/amd64/kubectl
RUN chmod +x kubectl
RUN mv kubectl /usr/local/bin/

RUN ln -s /root/.local/share/letsencrypt/bin/letsencrypt /usr/local/bin/letsencrypt
RUN rm -rf /etc/letsencrypt

CMD ["/letsencrypt/start.sh"]
