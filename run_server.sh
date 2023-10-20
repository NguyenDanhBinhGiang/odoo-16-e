DB_ARGS=()
function check_config() {
    param="$1"
    value="$2"
#    if grep -q -E "^\s*\b${param}\b\s*=" "$ODOO_RC" ; then
#        value=$(grep -E "^\s*\b${param}\b\s*=" "$ODOO_RC" |cut -d " " -f3|sed 's/["\n\r]//g')
#    fi;
    DB_ARGS+=("--${param}")
    DB_ARGS+=("${value}")
}

check_config "db_host" "$HOST"
check_config "db_port" "$DB_PORT"
check_config "db_user" "$USER"
check_config "db_password" "$PASSWORD"

echo "PARAMS: " "${DB_ARGS[@]}"

if [ ! -f /etc/init_odoo.lock ]; then
    echo "Odoo server need init!" &&
    touch /etc/odoo-config/init_odoo.lock &&
    python3 ./odoo-bin -c /server/setup/odoo-server.conf "${DB_ARGS[@]}" -i base --stop-after-init &&
    echo "Odoo server init successful"
fi
python3 ./odoo-bin -c /server/setup/odoo-server.conf "${DB_ARGS[@]}"
