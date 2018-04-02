# Container related settings
rails_root=/usr/share/nginx/html
drives_path=$rails_root/private/drives
system_path=$rails_root/private/system
database_conf_path=$rails_root/config/database.yml
schema_path=$rails_root/db/schema.rb

# Master
docker run -it --name cde-db-console-test \
--link cde-database-production:cde-database-production \
-v $(pwd)/database.yml:$database_conf_path \
-v $(pwd)/schema.rb:$schema_path \
-e "DRIVES_ROOT=$drives_path" -e "SYSTEM_ROOT=$system_path" \
-e "MAILGUN_DOMAIN=mail.kodethon.com" -e "MAILGUN_API_KEY=key-b4919c68dcbf8cd3dfc16fc6198d1641" \
jvlythical/cde-master:2.9.16-rc sh -c '/bin/bash'
