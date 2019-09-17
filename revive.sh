docker start cde-frontend
docker start cde-cache
docker start cde-master
docker start cde-load-balancer
docker start datadog-agent
sh migrate.sh
#docker start nginx-proxy
