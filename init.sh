cd reverse-proxy && sh start-reverse-proxy.sh

cd db && docker-compose up -d; cd ..
cd cache && sh start-cache.sh; cd ..
cd frontend && sh start-frontend-pro.sh; cd ..
cd master && sh start-master-pro.sh; cd ..

# Update the current default.conf to use the  master's ip addr
cd load-balancer
sh start-load-balancer.sh; cd ..
