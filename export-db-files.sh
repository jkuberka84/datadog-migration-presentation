# This script is for exporting/transferring the files, and database of a WordPress site.
# Started Febuary 6th, 2024 by Jason Kuberka

Put WordPress database credentials into variables

#DB Name
wpdbname=`cat wp-config.php | grep DB_NAME | cut -d \' -f 4`

#DB User
wpdbuser=`cat wp-config.php | grep DB_USER | cut -d \' -f 4`

#DB Password
wpdbpass=`cat wp-config.php | grep DB_PASSWORD | cut -d \' -f 4`

wpdbhost=`cat wp-config.php | grep DB_HOST | cut -d \' -f 4`

echo "db name is $wpdbname"
echo
echo "db user is $wpdbuser"
echo
echo "db pass is $wpdbpass"
echo
echo "db host is $wpdbhost"

mysqldump --default-character-set=utf8mb4 -u "$wpdbuser" -p"$wpdbpass"  "$wpdbname" > wp-database-backup-8317.sql

#Breakout SSH string into variables

echo "Enter SSH Command"
read sshcommand

ssh_user=$(echo "$sshcommand" | awk '{print $2}' | cut -d "@" -f 1)
ssh_host=$(echo "$sshcommand" | awk '{print $2}' | cut -d "@" -f 2)
ssh_port=$(echo "$sshcommand" | awk '/-p/{print $(NF)}')

echo "ssh_user is $ssh_user"
echo "ssh_host is $ssh_host"
echo "ssh_port is $ssh_port"


rsync -avz ./ ssh_user@ssh_host:~/home/public/
