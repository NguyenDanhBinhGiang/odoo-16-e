# Default dockerfile from github
FROM ndbghdvn/base-env-odoo-16-e

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

RUN useradd -ms /bin/bash odoo
RUN mkdir /server &&  \
    chown -R odoo /server && \
    mkdir -p /etc/odoo-data &&  \
    chown -R odoo /etc/odoo-data && \
    mkdir -p /etc/odoo-config  &&  \
    chown -R odoo /etc/odoo-config
WORKDIR /server

COPY --chown=odoo . .

# Expose Odoo services
EXPOSE 10000 8071 8072

USER odoo

#ENTRYPOINT ["/entrypoint.sh"]
CMD ["/server/run_server.sh"]