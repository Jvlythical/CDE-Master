# Frontend

if [ -z $(ls ../config/env.yml 2> /dev/null) ]; then
	echo 'Please create config/env.yml'
	exit
else
	# Export ENV variables
	export $(sed -e 's/:[^:\/\/]/=/g;s/$//g;s/ *=/=/g' ../config/env.yml)
fi

image=jvlythical/cde-frontend:4.0.8-rc
if [ -z $USE_LETSENCRYPT ]; then
	# Replace hostname marker with node host
	sed -e "s/__HOSTNAME__/$FRONTEND_HOSTNAME/" templates/template.conf > webapp.conf
	#s="\nssl on;\nssl_certificate /etc/ssl/ssl-bundle.crt;\nssl_certificate_key /etc/ssl/kodethon.key;\n"
	#sed -i "s/__SSL__/$s/" webapp.conf

	docker run -d --name cde-frontend -p 80:80 -p 443:443 \
	-v $(pwd)/../ssl/ssl-bundle.crt:/etc/ssl/ssl-bundle.crt \
	-v $(pwd)/../ssl/kodethon.key:/etc/ssl/kodethon.key \
	-v $(pwd)/webapp.conf:/etc/nginx/conf.d/webapp.conf \
	$image	
else
	echo 'Using letsencrypt...'

	# Replace hostname marker with node host
	sed -e "s/__HOSTNAME__/$FRONTEND_HOSTNAME/" templates/letsencrypt_template.conf > webapp.conf

	docker run -d --name cde-frontend \
		-e "VIRTUAL_HOST=$FRONTEND_HOSTNAME" \
		-e "HTTPS_METHOD=noredirect" \
		-e "LETSENCRYPT_HOST=$FRONTEND_HOSTNAME" \
		-e "LETSENCRYPT_EMAIL=$NODE_OWNER" \
		-v $(pwd)/webapp.conf:/etc/nginx/conf.d/webapp.conf \
		$image

	docker exec cde-frontend sh -c "ls scripts | grep scripts | xargs -I {} sed -i 's/location.host+\":8080/\"$BACKEND_HOSTNAME/' scripts/{}"


	#-e "VIRTUAL_PORT=443" \
	#-e "VIRTUAL_PROTO=https" \
	#docker exec $name mkdir /usr/share/nginx/html/public 2> /dev/null
	#docker exec $name certbot certonly --email $NODE_OWNER --agree-tos --text --non-interactive --webroot  -w /usr/share/nginx/html/public -d $FRONTEND_HOSTNAME
fi
