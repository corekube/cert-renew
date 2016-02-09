FROM nginx

RUN apt-get update && apt-get install -y git wget cron bc

RUN mkdir -p /letsencrypt/challenges/.well-known/acme-challenge
RUN git clone https://github.com/letsencrypt/letsencrypt /letsencrypt/app
WORKDIR /letsencrypt/app
RUN ./letsencrypt-auto; exit 0

# Install kubectl
RUN wget https://storage.googleapis.com/kubernetes-release/release/v1.1.7/bin/linux/amd64/kubectl
RUN chmod +x kubectl
RUN mv kubectl /usr/local/bin/

# Add some helper scripts for getting and saving scripts later
ADD fetch_certs.sh /letsencrypt/
ADD save_certs.sh /letsencrypt/
ADD recreate_pods.sh /letsencrypt/
ADD refresh_certs.sh /letsencrypt/
ADD start.sh /letsencrypt/

RUN ln -s /root/.local/share/letsencrypt/bin/letsencrypt /usr/local/bin/letsencrypt

WORKDIR /letsencrypt

ENTRYPOINT ./start.sh
