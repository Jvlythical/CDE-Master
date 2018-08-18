docker start cde-frontend
docker start cde-database-production
docker start cde-cache
docker start cde-master
docker start cde-load-balancer
sh migrate.sh
