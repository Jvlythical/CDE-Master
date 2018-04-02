docker run -d -p 80:80 -p 443:443 \
    --name nginx-proxy \
    -v $(pwd)/certs:/etc/nginx/certs:ro \
    -v /etc/nginx/vhost.d \
    -v /usr/share/nginx/html \
    -v /var/run/docker.sock:/tmp/docker.sock:ro \
    jwilder/nginx-proxy
