name=cde-load-balancer

if [ -z $(ls ../config/env.yml 2> /dev/null) ]; then
	echo 'Please create config/env.yml'
	exit
else
	# Export ENV variables
	export $(sed -e 's/:[^:\/\/]/=/g;s/$//g;s/ *=/=/g' ../config/env.yml)
fi

master_container_name=cde-master
master_ip_addr=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $master_container_name 2> /dev/null)
s="\tserver $master_ip_addr fail_timeout=30;\n"

if [ -z $USE_LETSENCRYPT ]; then
	sed -e "s/__MARKER__/$s/" templates/template.conf > default.conf
	sed -i "s/__HOSTNAME__/$BACKEND_HOSTNAME/" default.conf

	docker run -d -p 8080:443 --name $name \
		--network docker-internal \
		-v $(pwd)/../ssl/ssl-bundle.crt:/etc/ssl/ssl-bundle.crt \
		-v $(pwd)/../ssl/kodethon.key:/etc/ssl/kodethon.key \
		-v $(pwd)/default.conf:/etc/nginx/conf.d/default.conf:rw \
		-v $(pwd)/nginx.conf:/etc/nginx/nginx.conf nginx
else
	echo 'Using letsencrypt...'

	sed -e "s/__MARKER__/$s/" templates/letsencrypt_template.conf > default.conf
	sed -i "s/__HOSTNAME__/$BACKEND_HOSTNAME/" default.conf

	docker run -d --name $name \
		--network docker-internal \
		-e "VIRTUAL_HOST=$BACKEND_HOSTNAME"  \
		-e "LETSENCRYPT_HOST=$BACKEND_HOSTNAME" \
		-e "LETSENCRYPT_EMAIL=$NODE_OWNER" \
		-e "HTTPS_METHOD=noredirect" \
		-v $(pwd)/default.conf:/etc/nginx/conf.d/default.conf:rw \
		-v $(pwd)/nginx.conf:/etc/nginx/nginx.conf jvlythical/nginx
fi

