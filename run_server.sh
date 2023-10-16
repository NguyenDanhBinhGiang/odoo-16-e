if [ ! -f /etc/init_odoo.lock ]; then
    echo "Odoo server need init!" &&
    touch /etc/odoo-config/init_odoo.lock &&
    python3 /server/odoo-bin -c /server/setup/odoo-server.conf -i base --stop-after-init &&
    echo "Odoo server init successful"
fi
python3 /server/odoo-bin -c /server/setup/odoo-server.conf