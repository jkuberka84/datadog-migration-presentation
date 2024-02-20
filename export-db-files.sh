# This script is for exporting/transferring the files, and database of a WordPress site to Kinsta. Can be modified to transfer to another host.
# Started Febuary 6th, 2024 by Jason Kuberka

#find -name "wp-config.php" .



basewpdir=$(pwd | sed 's|/public_html.*||')

if compgen -c | grep -qE '\bwp\b'; then
    echo
    echo "Utilizing wp db export to export the database"

    echo
    wp db export $basewpdir/private_html/wp-database-backup-8317.sql
    
else
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


cd ..

clear

echo

#Breakout SSH string into variables

echo "Enter SSH Command"
read sshcommand

echo
echo
echo "The SSH command has been broken out into variables for rsync"
echo

ssh_user=$(echo "$sshcommand" | awk '{print $2}' | cut -d "@" -f 1)
ssh_host=$(echo "$sshcommand" | awk '{print $2}' | cut -d "@" -f 2)
ssh_port=$(echo "$sshcommand" | awk '/-p/{print $(NF)}')
echo
echo "ssh_user is $ssh_user"
echo "ssh_host is $ssh_host"
echo "ssh_port is $ssh_port"


if compgen -c | grep -qE '\brsync\b'; then
    rsync -avz --rsync-path="mkdir -p ~/migration/ && rsync" -e "ssh -p $ssh_port" "$basewpdir/private_html/wp-database-backup-8317.sql" "$basewpdir/public_html/" $ssh_user@$ssh_host:~/migration/
else

echo "Utilizing SCP to migrate"
    #scp command
    ssh -p $ssh_port $ssh_user@$ssh_host "mkdir -p ~/migration/ && scp -P $ssh_port $basewpdir/private_html/wp-database-backup-8317.sql $basewpdir/public_html/* ~/migration/"
fi


rm -v "$basewpdir/private_html/wp-database-backup-8317.sql"
