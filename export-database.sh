#Check if WP-CLI or mysqldump is available

if compgen -c | grep -qE '\bwp\b'; then
    echo
    echo "Utilizing wp db export to export the database"

    echo
    wp db export $basewpdir/private_html/wp-database-backup-8317.sql
    
else
    #WP-CLI not available, using mysqldump
    echo
    echo "Utilizing mysqldump to export the database"

    #DB Name
    wpdbname=`cat wp-config.php | grep DB_NAME | cut -d \' -f 4`

    #DB User
    wpdbuser=`cat wp-config.php | grep DB_USER | cut -d \' -f 4`

    wpdbhost=`cat wp-config.php | grep DB_HOST | cut -d \' -f 4`
    echo
    mysqldump --default-character-set=utf8mb4 -u "$wpdbuser" -p  "$wpdbname" > wp-database-backup-8317.sql


fi
