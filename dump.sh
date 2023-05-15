#!/bin/ash

set -e

echo "Job started: $(date)"

DATE=$(date +%Y%m%d_%H%M%S)
FILE="/dump/$PREFIX-$DATE.sql"

if [ ${PGROLES} eq "true" ]; then
## Dump the roles
echo "Dumping roles/users..."
pg_dumpall --roles-only --file=${FILE} -h "$PGHOST" -p "$PGPORT" -U "$PGUSER"
echo "Finisheed dumping roles..."
else
	touch ${FILE}
fi
## Add extra line
echo "" >> ${FILE}
echo "Dumping database..."
# Add in the database schema/datas
pg_dump -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDB" --rows-per-insert=1024 >> ${FILE}
echo "Finished dumping database"
# Zip them all back up
echo "Zipping the backup"
gzip "$FILE"
echo "Zip completed"
if [ ! -z "$DELETE_OLDER_THAN" ]; then
	echo "Deleting backups older than: ${DELETE_OLDER_THAN}"
	find /dump/* -mmin "+$DELETE_OLDER_THAN" -exec rm {} \;
fi



echo "Job finished: $(date)"
