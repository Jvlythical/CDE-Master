lb_name=cde-load-balancer
temp_master=cde-master-temp
master=cde-master

# Start a temp node container
docker start $temp_master 2> /dev/null
sleep 1

# If the temp node has not been started, create one
temp_ip_addr=$(docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $temp_master 2> /dev/null)
if [ -z "$(docker ps | grep $temp_master)" ]; then
	echo 'No backup node available, starting one...'
	cd master; sh start-master-pro.sh $temp_master; cd ..
	sleep 5
	temp_ip_addr=$($docker_container_ip_addr $temp_master)
fi
echo "Started backup master with ip addr: $temp_ip_addr"

# Update the current default.conf to use the temp master's ip addr
cd load-balancer; cat default.conf > default.conf.bak
if [ -z $(ls ../config/env.yml 2> /dev/null) ]; then
	echo 'Please create config/env.yml'
	exit
else
	# Export ENV variables
	export $(sed -e 's/:[^:\/\/]/=/g;s/$//g;s/ *=/=/g' ../config/env.yml)
fi
s="\tserver $temp_ip_addr fail_timeout=30;\n"
if [ -z $USE_LETSENCRYPT ]; then
	sed -e "s/__MARKER__/$s/" templates/template.conf > tmp.conf
else
	echo 'Using letsencrypt...'
	sed -e "s/__MARKER__/$s/" templates/letsencrypt_template.conf > tmp.conf
fi
sed -i "s/__HOSTNAME__/$BACKEND_HOSTNAME/" tmp.conf
# Do not use in place replacement! Will break docker mount :/
cat tmp.conf > default.conf && rm tmp.conf
cd ..
sleep 5
docker exec $lb_name service nginx reload

# Remove the current master and start a new one
echo 'Removing frontend container...'
docker rm -f cde-frontend
echo 'Removing master container...'
docker rm -f cde-master
sh driver.sh
sleep 10

# Create a new default.conf
old_ip_addr=$(docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $temp_master)
new_ip_addr=$(docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $master)
echo "Old ip addr: $old_ip_addr - New ip addr: $new_ip_addr"
s="\tserver $new_ip_addr fail_timeout=30;\n"
cd load-balancer
if [ -z $USE_LETSENCRYPT ]; then
	sed -e "s/__MARKER__/$s/" templates/template.conf > tmp.conf
else
	echo 'Using letsencrypt...'

	sed -e "s/__MARKER__/$s/" templates/letsencrypt_template.conf > tmp.conf
fi
sed -i "s/__HOSTNAME__/$BACKEND_HOSTNAME/" tmp.conf
cat tmp.conf > default.conf && rm tmp.conf
docker exec $lb_name service nginx reload
cd ..

# All done, stop backup
docker stop $temp_master
cd load-balancer; rm default.conf.bak; cd ..

