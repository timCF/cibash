#!/bin/sh


GIT_FILENAME="$(pwd)/gitenv.sh"
ID_RSA_FILENAME="$(pwd)/id_rsa"

# define functions
function tmp_files_new {
	echo "creating tmp files" &&
	echo "$ID_RSA" > $ID_RSA_FILENAME &&
	GIT_FILECONTENT="exec /usr/bin/ssh -o StrictHostKeyChecking=no -i $ID_RSA_FILENAME \"\$@\"" &&
	echo $GIT_FILECONTENT > $GIT_FILENAME &&
	chmod a+x $GIT_FILENAME &&
	chmod 600 $ID_RSA_FILENAME
	echo "tmp files created"
}
function tmp_files_delete {
	echo "deleting tmp files" &&
	rm -f $ID_RSA_FILENAME &&
	rm -f $GIT_FILENAME &&
	echo "tmp files deleted"
}
function cleanup {
	echo "GOT EXCEPTION, TRY CLEANUP" &&
	tmp_files_delete &&
	echo "GOT EXCEPTION, CLEANUP DONE"
	return 1
}

function main {
	tmp_files_delete &&
	tmp_files_new &&
	export GIT_SSH=$GIT_FILENAME &&
	echo "test ssh key : $(ssh -o StrictHostKeyChecking=no -i $ID_RSA_FILENAME git@git.maxbet.asia)" &&
	git submodule update --init --recursive &&
	mix deps.get &&
	mix compile.protocols &&
	tmp_files_delete &&
	echo "SUCCESS"
}

# execute
main || cleanup
