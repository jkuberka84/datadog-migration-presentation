#Rsync files from current logged in server to Kinsta

#Breakout SSH string into variables

echo "Enter SSH Command"
read sshcommand

echo
echo
echo "The SSH command has been broken out into variables for rsync"
echo

#Put SSH info into variables

ssh_user=$(echo "$sshcommand" | awk '{print $2}' | cut -d "@" -f 1)
ssh_host=$(echo "$sshcommand" | awk '{print $2}' | cut -d "@" -f 2)
ssh_port=$(echo "$sshcommand" | awk '/-p/{print $(NF)}')
echo
echo "ssh_user is $ssh_user"
echo "ssh_host is $ssh_host"
echo "ssh_port is $ssh_port"


#Check if Rsync is available, and if not, use SCP
if compgen -c | grep -qE '\brsync\b'; then
    rsync -avz --rsync-path="mkdir -p ~/migration/ && rsync" -e "ssh -p $ssh_port" "$basewpdir/private_html/wp-database-backup-8317.sql" "$basewpdir/public_html/" $ssh_user@$ssh_host:~/migration/
else

echo "Utilizing SCP to migrate"
    #scp command
    ssh -p $ssh_port $ssh_user@$ssh_host "mkdir -p ~/migration/ && scp -P $ssh_port $basewpdir/private_html/wp-database-backup-8317.sql $basewpdir/public_html/* ~/migration/"
fi
