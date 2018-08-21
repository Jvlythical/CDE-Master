# Frontend
docker run -d --name cde-frontend -p 80:80 -p 443:443  \
-e "VIRTUAL_HOST=www.kodethon.com" \
-v $(pwd)/../ssl/ssl-bundle.crt:/etc/ssl/ssl-bundle.crt \
-v $(pwd)/../ssl/kodethon.key:/etc/ssl/kodethon.key \
jvlythical/cde-frontend:3.9.0-rc
