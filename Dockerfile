FROM ubuntu:22.04

ARG FETCH_VERSION=latest
ARG OBSERVIUM_DB_HOST=mariadb
ARG OBSERVIUM_DB_NAME=observium
ARG OBSERVIUM_DB_USER=observium
ARG OBSERVIUM_DB_PASS=passw0rd
ARG OBSERVIUM_BASE_URL=http://localhost:80

LABEL maintainer="oabaiadze@gmail.com"
LABEL version="1.7"
LABEL description="Docker container for Observium Community Edition"
LABEL fetch_version="$FETCH_VERSION"

ENV FETCH_VERSION=$FETCH_VERSION
ENV LANG=en_US.UTF-8
ENV LANGUAGE=$LANG

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt upgrade -y && \
    apt install -y  cron \
                    locales \
                    supervisor \
                    logrotate \
                    curl \
                    wget \
                    nginx \
                    php8.1-cli \
                    php8.1-fpm \
                    php8.1-mysql \
                    php8.1-gd \
                    php8.1-bcmath \
                    php8.1-mbstring \
                    php8.1-opcache \
                    php8.1-curl \
                    php-apcu \
                    php-pear \
                    libphp-phpmailer \
                    libvirt-clients \
                    snmp \
                    fping \
                    mysql-client \
                    rrdtool \
                    subversion \
                    whois \
                    mtr-tiny \
                    ipmitool \
                    graphviz \
                    imagemagick \
                    python3-pip && \
    apt clean && \
    rm -f /etc/nginx/sites-enabled/default

RUN locale-gen $LANG

RUN mkdir -p /opt/observium /opt/observium/logs /opt/observium/rrd && \
    chmod 755 /opt/observium /opt/observium/logs /opt/observium/rrd && \
    wget -qO /opt/observium-community-${FETCH_VERSION}.tar.gz http://www.observium.org/observium-community-${FETCH_VERSION}.tar.gz && \
    tar -zxvf /opt/observium-community-${FETCH_VERSION}.tar.gz -C /opt && \
    rm /opt/observium-community-${FETCH_VERSION}.tar.gz

COPY observium-init.sh /opt/observium/observium-init.sh
RUN chmod +x /opt/observium/observium-init.sh

COPY nginx.conf /etc/nginx/nginx.conf
COPY observium /etc/nginx/sites-available/observium

# Update php-fpm.conf to use TCP socket
RUN sed -i 's|listen = /run/php/php8.1-fpm.sock|listen = 127.0.0.1:9000|' /etc/php/8.1/fpm/pool.d/www.conf

COPY supervisord.conf /etc/supervisord.conf

# Install latest versions of specific packages using pip
RUN pip install --upgrade pip && \
    pip install PyMySQL cryptography

WORKDIR /opt/observium

ENTRYPOINT [ "/opt/observium/observium-init.sh" ]
CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]

EXPOSE 80/tcp

VOLUME ["/opt/observium/logs","/opt/observium/rrd"]
