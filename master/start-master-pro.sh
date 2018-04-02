# Container related settings
rails_root=/usr/share/nginx/html
drives_path=$rails_root/private/drives
system_path=$rails_root/private/system
database_conf_path=$rails_root/config/database.yml
production_log_path=$rails_root/log/production.log
schema_path=$rails_root/db/schema.rb

# Master
docker run -d --name cde-master -p 8080:8080 \
--link cde-cache:memcache \
--link cde-database-production:cde-database-production \
-v $(pwd)/database.yml:$database_conf_path \
-v $(pwd)/logs/production.log:$production_log_path \
-v $(pwd)/../ssl/ssl-bundle.crt:/etc/ssl/ssl-bundle.crt \
-v $(pwd)/../ssl/kodethon.key:/etc/ssl/kodethon.key \
-v $(pwd)/schema.rb:$schema_path \
 -v $(pwd)/overrides/assignment_controller.rb:$rails_root/app/controllers/assignment_controller.rb \
-e "DRIVES_ROOT=$drives_path" -e "SYSTEM_ROOT=$system_path" -e "RAILS_ENV=production" \
-e "MAILGUN_DOMAIN=mail.kodethon.com" -e "MAILGUN_API_KEY=key-b4919c68dcbf8cd3dfc16fc6198d1641" \
jvlythical/cde-master:2.9.16-rc sh -c '/sbin/run.sh'

