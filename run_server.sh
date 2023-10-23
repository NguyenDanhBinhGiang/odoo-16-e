#!/bin/bash

DB_ARGS=()
function check_config() {
    param="$1"
    if [[ -n "$2" ]]
    then
#        echo "not Empty";
        value="$2"
        DB_ARGS+=("--${param}")
        DB_ARGS+=("${value}")
#    else
#        echo "empty"
    fi
}

check_config "db_host" "$DB_HOST"
check_config "db_port" "$DB_PORT"
check_config "db_user" "$DB_USER"
check_config "db_password" "$DB_PASSWORD"
check_config "database" "$DB_NAME"

echo "PARAMS: " "${DB_ARGS[@]}"
./wait-for-psql.py ${DB_ARGS[@]} --timeout=30
if [ ! -f /etc/init_odoo.lock ]; then
    echo "Odoo server need init!" &&
    touch /etc/odoo-config/init_odoo.lock &&
    psql postgres://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_NAME -c "select 'drop table if exists \"' || tablename || '\" cascade;'  from pg_tables where schemaname = 'public';"&&
    python3 ./odoo-bin -c /server/setup/odoo-server.conf "${DB_ARGS[@]}" -i base --stop-after-init &&
    echo "Odoo server init successful"
fi
python3 ./odoo-bin -c /server/setup/odoo-server.conf "${DB_ARGS[@]}"
