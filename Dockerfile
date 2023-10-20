# Default dockerfile from github
FROM debian:bullseye-slim
MAINTAINER Odoo S.A. <info@odoo.com>

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

RUN mkdir "/server"
RUN mkdir "/etc/odoo-data"
WORKDIR /server
COPY . .
#VOLUME "/server"

# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG C.UTF-8

RUN echo -e '\033[31m Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf \033[0m'
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        dirmngr \
        fonts-noto-cjk \
        gnupg \
        libssl-dev \
        node-less \
        npm \
        python3-magic \
        python3-num2words \
        python3-odf \
        python3-pdfminer \
        python3-pip \
        python3-dev libldap2-dev libsasl2-dev ldap-utils gcc g++\
        python3-phonenumbers \
        python3-pyldap \
        python3-qrcode \
        python3-renderpm \
        python3-setuptools \
        python3-slugify \
        python3-vobject \
        python3-watchdog \
        python3-xlrd \
        python3-xlwt \
        xz-utils \
    && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.buster_amd64.deb \
    && echo 'ea8277df4297afc507c61122f3c349af142f31e5 wkhtmltox.deb' | sha1sum -c - \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

RUN echo -e '\033[31m install latest postgresql-client \033[0m'
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ bullseye-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && repokey='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
    && gpg --batch --armor --export "${repokey}" > /etc/apt/trusted.gpg.d/pgdg.gpg.asc \
    && gpgconf --kill all \
    && rm -rf "$GNUPGHOME" \
    && apt-get update  \
    && apt-get install --no-install-recommends -y postgresql-client \
    && rm -f /etc/apt/sources.list.d/pgdg.list \
    && rm -rf /var/lib/apt/lists/*

RUN echo -e '\033[31m Install rtlcss (on Debian buster) \033[0m'
RUN npm install -g rtlcss

# install python packages
RUN echo -e '\033[31m install python packages \033[0m'
RUN pip3 install --upgrade setuptools && pip3 install --upgrade wheel &&  pip3 install openpyxl
COPY requirements.txt .
RUN pip3 install -r requirements.txt

# Install Odoo
#ENV ODOO_VERSION 15.0
#ARG ODOO_RELEASE=20221025
#ARG ODOO_SHA=923fdec85ac9a4230fc93af00d12d8911a0613b4
#RUN curl -o odoo.deb -sSL http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb \
#    && echo "${ODOO_SHA} odoo.deb" | sha1sum -c - \
#    && apt-get update \
#    && apt-get -y install --no-install-recommends ./odoo.deb \
#    && rm -rf /var/lib/apt/lists/* odoo.deb


# Copy entrypoint script and Odoo configuration file
RUN echo -e '\033[31m Copy entrypoint script and Odoo configuration file \033[0m'
#COPY ./entrypoint.sh /
#COPY ./odoo.conf /etc/odoo/

# Set permissions and Mount /var/lib/odoo to allow restoring filestore and /mnt/extra-addons for users addons
RUN echo -e '\033[31m Set permissions and Mount \033[0m'
#RUN chown odoo /etc/odoo/odoo.conf \
#    && mkdir -p /mnt/extra-addons \
#    && chown -R odoo /mnt/extra-addons
#VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]
RUN useradd -ms /bin/bash odoo
RUN chown odoo -R /server \
    && mkdir -p /etc/odoo-config \
    && chown -R odoo /etc/odoo-config

# Expose Odoo services
EXPOSE 10000 8071 8072

# Set the default config file
#ENV ODOO_RC /etc/odoo/odoo.conf

#COPY wait-for-psql.py /server/wait-for-psql.py
#COPY run_server.sh /server/run_server.sh

# Copy add-ons
#COPY ./custom_addon /mnt/extra-addons/
#COPY ./enterpriseaddons /mnt/extra-addons/

# Set default user when running the container
#usermod -u 1000 odoo
USER odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/run_server.sh"]
