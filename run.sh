#/bin/bash

cat > /var/www/config.php <<EOF
<?php
    putenv('TTRSS_DB_TYPE=${DB_TYPE}');
    putenv('TTRSS_DB_HOST=${DB_HOST}');
    putenv('TTRSS_DB_PORT=${DB_PORT}');
    putenv('TTRSS_DB_USER=${DB_USER}');
    putenv('TTRSS_DB_PASS=${DB_PASS}');
    putenv('TTRSS_DB_NAME=${DB_NAME}');
    putenv('TTRSS_SELF_URL_PATH=${SELF_URL}${SELF_URL_PATH}');
EOF

sudo -u www-data php update.php --update-schema=force-yes
ret=${?}
[ ${ret} -ne 0 ] && exit ${ret}

sed -i -e "s|##SELF_URL_PATH##|${SELF_URL}${SELF_URL_PATH}|" /etc/nginx/sites-enabled/ttrss
sed -i -e "s|##TTRSS_PATH##|${SELF_URL_PATH}|" /etc/nginx/sites-enabled/ttrss

supervisord -c /etc/supervisor/conf.d/supervisord.conf
