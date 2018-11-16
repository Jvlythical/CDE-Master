# Container related settings
rails_root=/usr/share/nginx/html
drives_path=$rails_root/private/drives
system_path=$rails_root/private/system
database_conf_path=$rails_root/config/database.yml
production_log_path=$rails_root/log/production.log
schema_path=$rails_root/db/schema.rb


if [ -z $(ls ../config/credentials.yml 2> /dev/null) ]; then
	echo 'Please create config/credentials.yml'
	exit
else
	# Export ENV variables
	export $(sed -e 's/:[^:\/\/]/=/g;s/$//g;s/ *=/=/g' ../config/credentials.yml)
fi

if [ -z $MAILGUN_DOMAIN ]; then
	echo "MAILGUN_DOMAIN is not set."
	exit
fi

if [ -z $MAILGUN_API_KEY ]; then
	echo "MAILGUN_API_KEY is not set."
	exit
fi

container_name=$1
if [ -z "$container_name" ]; then
	container_name=cde-master
fi

# Master
docker run -d --name $container_name \
--link cde-cache:memcache \
--link cde-database-production:cde-database-production \
-v $(pwd)/../config/database.yml:$database_conf_path \
-v $(pwd)/logs/production.log:$production_log_path \
-v $(pwd)/schema.rb:$schema_path \
-e "DRIVES_ROOT=$drives_path" -e "SYSTEM_ROOT=$system_path" -e "RAILS_ENV=production" \
-e "MAILGUN_DOMAIN=$MAILGUN_DOMAIN" -e "MAILGUN_API_KEY=$MAILGUN_API_KEY" \
-e "STRIPE_PUBLISHABLE_KEY=$STRIPE_PUBLISHABLE_KEY" -e "STRIPE_SECRET_KEY=$STRIPE_SECRET_KEY" \
jvlythical/cde-master:4.0.3-rc sh -c '/sbin/run.sh'

#-v $(pwd)/../ssl/ssl-bundle.crt:/etc/ssl/ssl-bundle.crt \
#-v $(pwd)/../ssl/kodethon.key:/etc/ssl/kodethon.key \
