docker exec cde-database-production sh -c "nice -n 19 su postgres -c 'vacuumdb --all --full --analyze'"

# dump all databases once every 24 hours
#45 4 * * * root nice -n 19 su - postgres -c "pg_dumpall --clean" | gzip -9 > /var/local/backup/postgres/postgres_all.sql.gz

# vacuum all databases every night (full vacuum on Sunday night, lazy vacuum every other night)
#45 3 * * 0 root nice -n 19 su - postgres -c "vacuumdb --all --full --analyze"
#45 3 * * 1-6 root nice -n 19 su - postgres -c "vacuumdb --all --analyze --quiet"

# re-index all databases once a week
#0 3 * * 0 root nice -n 19 su - postgres -c 'psql -t -c "select datname from pg_database order by datname;" | xargs -n 1 -I"{}" -- psql -U postgres {} -c "reindex database {};"'

