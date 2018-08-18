name=cde-load-balancer

docker run -d -p 8080:443 --name $name \
-v $(pwd)/../ssl/ssl-bundle.crt:/etc/ssl/ssl-bundle.crt \
-v $(pwd)/../ssl/kodethon.key:/etc/ssl/kodethon.key \
-v $(pwd)/default.conf:/etc/nginx/conf.d/default.conf:rw \
-v $(pwd)/nginx.conf:/etc/nginx/nginx.conf nginx
