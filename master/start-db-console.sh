# Container related settings
rails_root=/usr/share/nginx/html
drives_path=$rails_root/private/drives
system_path=$rails_root/private/system
database_conf_path=$rails_root/config/database.yml
schema_path=$rails_root/db/schema.rb

# Export ENV variables
export $(sed -e 's/:[^:\/\/]/=/g;s/$//g;s/ *=/=/g' ../config/env.yml)

if [ -z $MAILGUN_DOMAIN ]; then
	echo "MAILGUN_DOMAIN is not set."
	exit
fi

if [ -z $MAILGUN_API_KEY ]; then
	echo "MAILGUN_API_KEY is not set."
	exit
fi

# Master
docker run -it --name cde-db-console \
--link cde-database-production:cde-database-production \
-v $(pwd)/../config/database.yml:$database_conf_path \
-v $(pwd)/schema.rb:$schema_path \
-e "DRIVES_ROOT=$drives_path" -e "SYSTEM_ROOT=$system_path" \
-e "MAILGUN_DOMAIN=$MAILGUN_DOMAIN" -e "MAILGUN_API_KEY=$MAINGUN_API_KEY" \
jvlythical/cde-master:4.0.6-rc sh -c '/bin/bash'
