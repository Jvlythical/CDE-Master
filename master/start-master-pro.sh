if [ -z $(ls ../config/env.yml 2> /dev/null) ]; then
	echo 'Please create config/env.yml'
	exit
else
	# Export ENV variables
	export $(sed -e 's/:[^:\/\/]/=/g;s/$//g;s/ *=/=/g' ../config/env.yml)
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

log_file=$(pwd)/logs/production.log
if [ ! -e "$log_file" ]; then
	mkdir logs 2> /dev/null
	touch "$log_file"
fi

database_config=$(pwd)/../config/database.yml
if [ ! -e "$datbase_config" ]; then
	touch "$database_config"
fi

schema_file=$(pwd)/schema.rb
if [ ! -e "$schema_file" ]; then
	touch "$schema_file"
fi

github_pkey_file=$(pwd)/../config/private_key.pem
if [ ! -e "$github_pkey_file" ]; then
	touch "$github_pkey_file"
fi

# Container related settings
rails_root=/usr/share/nginx/html
drives_path=$rails_root/private/drives
system_path=$rails_root/private/system
database_conf_path=$rails_root/config/database.yml
production_log_path=$rails_root/log/production.log
schema_path=$rails_root/db/schema.rb
github_pkey_path=$rails_root/config/private_key.pem

# Master
docker run -d --name $container_name -h "$(uname -n)" \
--network docker-internal \
-v $database_config:$database_conf_path \
-v $log_file:$production_log_path \
-v $schema_file:$schema_path \
-v $github_pkey_file:$github_pkey_path \
-e "DRIVES_ROOT=$drives_path" -e "SYSTEM_ROOT=$system_path" -e "RAILS_ENV=production" \
-e "MAILGUN_DOMAIN=$MAILGUN_DOMAIN" -e "MAILGUN_API_KEY=$MAILGUN_API_KEY" \
-e "STRIPE_PUBLISHABLE_KEY=$STRIPE_PUBLISHABLE_KEY" -e "STRIPE_SECRET_KEY=$STRIPE_SECRET_KEY" \
-e "MEMCACHE_HOSTNAME=cde-cache" \
jvlythical/cde-master:4.1.1-rc sh -c '/sbin/run.sh'

#-v $(pwd)/../ssl/ssl-bundle.crt:/etc/ssl/ssl-bundle.crt \
#-v $(pwd)/../ssl/kodethon.key:/etc/ssl/kodethon.key \
#--link cde-cache:memcache \
#--link cde-database-production:cde-database-production \
