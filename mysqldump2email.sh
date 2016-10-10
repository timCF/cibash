#!/bin/sh

# check and prepare args
if [[ $# -ne 5 ]]; then
	echo "need 5 args : period in seconds, mysql database, gmail-sender, gmail-password, mail-receiver"
	exit 1
fi

PERIOD=$1
DATABASE=$2
GMAIL_SENDER=$3
GMAIL_SENDER_PASSWORD=$4
MAIL_RECEIVER=$5

# define functions
tmp_files_new() {
	echo "creating tmp files" &&
	mysqldump -u root -h 127.0.0.1 $DATABASE > "./$DATABASE.sql" &&
	echo "tmp files created"
}
tmp_files_delete() {
	echo "deleting tmp files" &&
	rm -f "./$DATABASE.sql" &&
	echo "tmp files deleted"
}
cleanup() {
	echo "GOT EXCEPTION, TRY CLEANUP" &&
	tmp_files_delete &&
	echo "GOT EXCEPTION, CLEANUP DONE, sleep 120 seconds" &&
	return 1
}

main() {
	tmp_files_delete &&
	tmp_files_new &&
	curl --url "smtps://smtp.gmail.com:465" --ssl-reqd --mail-from $GMAIL_SENDER --mail-rcpt $MAIL_RECEIVER --upload-file "./$DATABASE.sql" --user "$GMAIL_SENDER:$GMAIL_SENDER_PASSWORD" --insecure &&
	tmp_files_delete &&
	echo "SUCCESS"
}

# execute
while true; do
	echo "start execution script ..." &&
	main || cleanup &&
	echo "execution done, sleep $PERIOD seconds ..." &&
	sleep $PERIOD
done
