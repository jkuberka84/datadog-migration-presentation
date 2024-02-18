# This script is for importing a site's files, and database of a WordPress site.
# Started Febuary 8th, 2024 by Jason Kuberka for Datadog Presentation

cd ~/public/
wp --path=./public/ db reset --yes > /dev/null 2>&1

#Set Site root directory for Cloudways

basewpdir=$(pwd | sed 's|/public.*||')

mkdir -p "$basewpdir/private/old-files"

mv "$basewpdir/public/wp-config.php" "$basewpdir/private/old-files/wp-config-orig.php"

mv ./* "$basewpdir/private/old-files"
mv ./.* "$basewpdir/private/old-files"


cd ~/migration

mv ./* "$basewpdir/public/"
mv ./.* "$basewpdir/public/"


cd "$basewpdir/public/"

# Get WP-Config Credentials

echo "Syncing Database Credentials"
echo 
echo 
#DB Name
newwpdbname=$(cat "$basewpdir/private/old-files/wp-config-orig.php" | grep DB_NAME | cut -d \' -f 4)

#DB User
newwpdbuser=$(cat "$basewpdir/private/old-files/wp-config-orig.php" | grep DB_USER | cut -d \' -f 4)

#DB Password
newwpdbpass=$(cat "$basewpdir/private/old-files/wp-config-orig.php" | grep DB_PASSWORD | cut -d \' -f 4)

#DB Host
newwpdbhost=$(cat "$basewpdir/private/old-files/wp-config-orig.php" | grep DB_HOST | cut -d \' -f 4)

sed -i "/DB_HOST/s/'[^']*'/'$newwpdbhost'/2" wp-config.php
sed -i "/DB_NAME/s/'[^']*'/'$newwpdbname'/2" wp-config.php
sed -i "/DB_USER/s/'[^']*'/'$newwpdbuser'/2" wp-config.php
sed -i "/DB_PASSWORD/s/'[^']*'/'$newwpdbpass'/2" wp-config.php

#Import Database

#mv "$basewpdir/migration/wp-database-backup-8317.sql" "$basewpdir/public/wp-database-backup-8317.sql"

wp db import wp-database-backup-8317.sql
mv "wp-database-backup-8317.sql" "$basewpdir/private/old-files/wp-database-backup-8317.sql"


#Install Required 

echo "Installing Platform Software Package"

mkdir "$basewpdir/public/wp-content/mu-plugins"
cd "$basewpdir/public/wp-content/mu-plugins"

wget "https://kinsta.com/kinsta-tools/kinsta-mu-plugins.zip"
unzip "kinsta-mu-plugins.zip"

cd "$basewpdir/public/wp-content/plugins"

#Loops through Plugin Directory
for plugindirectory in $(find "$basewpdir/public/wp-content/plugins/" -maxdepth 1 -type d); do

# Checks to see if the plugin is active
    if wp plugin is-active "$(basename "$plugindirectory")"; then

        #Plugins with issues, and additional actions
        case "$(basename "$plugindirectory")" in

            breeze)
                echo "Incompatible Plugin, disabling it"
                wp plugin deactivate "$(basename "$plugindirectory")"
                mv "$basewpdir/public/wp-content/plugins/$(basename "$plugindirectory")" "$basewpdir/private/old-files/"

            ;;
            phpexec)
                echo "Exec-php is Active"
                echo
                echo "Check Confluence at https://mycompany.atlassian.net/wiki/spaces/Exec+Plugin+Issues"
            ;;
        esac

    fi
done
