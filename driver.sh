cd cache && sh start-cache.sh 2> /dev/null; cd .. 
echo 'Starting frontend container...'
cd frontend && sh start-frontend-pro.sh 2> /dev/null; cd ..
echo 'Starting master container...'
cd master && sh start-master-pro.sh
