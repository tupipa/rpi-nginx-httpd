FROM resin/rpi-raspbian

########################
LABEL Description="Combine NGINX reverse proxy and httpd(Apache2 web server) into one Docker image for Raspberry Pi. \
      The Dockerfile is based on: https://github.com/lroguet/rpi-nginx-proxy." \
      Vendor="Lele Ma" \
      Version="0.1"

# Install wget and install/updates certificates
RUN apt-get update \
 && apt-get install -y -q --no-install-recommends \
    ca-certificates \
    git \
    mercurial \
 && apt-get clean \
 && rm -r /var/lib/apt/lists/*

RUN apt-get update \
 && apt-get install -y -q --no-install-recommends \
    golang \
 && apt-get clean \
 && rm -r /var/lib/apt/lists/*

RUN apt-get update \
 && apt-get install -y -q --no-install-recommends \
    nginx \
    wget \
 && apt-get clean \
 && rm -r /var/lib/apt/lists/*

# Configure Nginx and apply fix for very long server names
RUN echo "daemon off;" >>/etc/nginx/nginx.conf \
 && sed -i 's/^http {/&\n    server_names_hash_bucket_size 128;/g' /etc/nginx/nginx.conf

# Install Forego
ENV GOPATH /opt/go
ENV PATH $PATH:$GOPATH/bin
RUN go get -u github.com/ddollar/forego

ENV DOCKER_GEN_VERSION 0.7.3

RUN wget https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-armhf-$DOCKER_GEN_VERSION.tar.gz \
 && tar -C /usr/local/bin -xvzf docker-gen-linux-armhf-$DOCKER_GEN_VERSION.tar.gz \
 && rm /docker-gen-linux-armhf-$DOCKER_GEN_VERSION.tar.gz

COPY data /app/
WORKDIR /app/

ENV DOCKER_HOST unix:///tmp/docker.sock

VOLUME ["/etc/nginx/certs"]

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["forego", "start", "-r"]

RUN apt-get update && apt-get install apt-utils -y && apt-get install apache2 -y


