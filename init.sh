if [ -z $(ls ../config/env.yml 2> /dev/null) ]; then
	echo 'Please create config/env.yml'
	exit
else
	# Export ENV variables
	export $(sed -e 's/:[^:\/\/]/=/g;s/$//g;s/ *=/=/g' ../config/env.yml)
fi

cd reverse-proxy && sh start-reverse-proxy.sh

cd db && docker-compose up -d; cd ..
cd cache && sh start-cache.sh; cd ..
cd frontend && sh start-frontend-pro.sh; cd ..
cd master && sh start-master-pro.sh; cd ..

docker exec cde-master sh -c "export CDE_GROUP_PASSWORD='$GROUP_PASSWORD'; rake admin:create_cde_group"

# Update the current default.conf to use the  master's ip addr
cd load-balancer
sh start-load-balancer.sh; cd ..
