#!/bin/bash
set -e

until mysql -h $OBSERVIUM_DB_HOST -u root -p$MYSQL_ROOT_PASSWORD -e "SHOW DATABASES;"; do
  >&2 echo "MariaDB is unavailable - sleeping"
  sleep 5
done

if [ ! -f /opt/observium/config.php ]; then
    cp /opt/observium/config.php.default /opt/observium/config.php
fi

DB_TABLES=$(mysql -h $OBSERVIUM_DB_HOST -u $OBSERVIUM_DB_USER -p$OBSERVIUM_DB_PASS $OBSERVIUM_DB_NAME -e "SHOW TABLES;" | wc -l)

if [ "$DB_TABLES" -eq 0 ]; then
    echo "Initializing Observium database schema..."
    ./discovery.php -u
    echo "Database initialized."
fi

ADMIN_EXISTS=$(mysql -h $OBSERVIUM_DB_HOST -u $OBSERVIUM_DB_USER -p$OBSERVIUM_DB_PASS $OBSERVIUM_DB_NAME -e "SELECT username FROM users WHERE username='$OBSERVIUM_ADMIN_USER';" | wc -l)

if [ "$ADMIN_EXISTS" -eq 0 ]; then
    echo "Creating admin user..."
    ./adduser.php $OBSERVIUM_ADMIN_USER $OBSERVIUM_ADMIN_PASS 10
fi

if [ ! -L /etc/nginx/sites-enabled/observium ]; then
    ln -s /etc/nginx/sites-available/observium /etc/nginx/sites-enabled/observium
    service nginx reload
fi

exec "$@"
