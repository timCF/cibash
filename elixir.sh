#!/bin/sh

# check and prepare args
if [[ $# -ne 4 ]]; then
	echo "need 4 args"
	exit 1
fi
THIS_APP=$1
ERLANG_NODE=$2
RELEASE_SERVER=$3
RELEASE_MODE=$4
RELEASE_FILE="$(pwd)/rel/$THIS_APP/releases/0.0.1/$THIS_APP.tar.gz"
GIT_FILENAME="$(pwd)/gitenv.sh"
ID_RSA_FILENAME="$(pwd)/id_rsa"
if [[ ! $RELEASE_SERVER =~ ^[^@]+@[^@]+$ ]]; then
	echo "bad release server name $RELEASE_SERVER"
	exit 1
fi
if [[ ! $RELEASE_MODE =~ ^(build|run)$ ]]; then
	echo "bad release mode $RELEASE_MODE"
	exit 1
fi

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
function deploy {
	local RELEASES_DIR="~/elixir_releases" &&
	if [[ $RELEASE_MODE =~ ^run$ ]]; then
		local DEPLOY_BEGIN="sudo supervisorctl stop $ERLANG_NODE &&"
		local DEPLOY_END="&& sudo supervisorctl start $ERLANG_NODE"
	else
		local DEPLOY_BEGIN=""
		local DEPLOY_END=""
	fi
	ssh -o StrictHostKeyChecking=no -i $ID_RSA_FILENAME $RELEASE_SERVER "$DEPLOY_BEGIN cd $RELEASES_DIR && rm -rf $ERLANG_NODE && mkdir $ERLANG_NODE" &&
	scp -rp -o StrictHostKeyChecking=no -i $ID_RSA_FILENAME $RELEASE_FILE "$RELEASE_SERVER:$RELEASES_DIR/$ERLANG_NODE/$ERLANG_NODE.tar.gz" &&
	ssh -o StrictHostKeyChecking=no -i $ID_RSA_FILENAME $RELEASE_SERVER "cd $RELEASES_DIR/$ERLANG_NODE && tar xvfz $ERLANG_NODE.tar.gz && sed -i 's/-sname\ $THIS_APP/-sname\ $ERLANG_NODE/g' ./releases/0.0.1/vm.args $DEPLOY_END"
}
function maybe_check_silverb {
	if grep -q "silverb" "./mix.lock" ; then
		mix silverb.on &&
		mix silverb.check &&
		mix silverb.off
	else
		return 0
	fi
}
function main {
	tmp_files_delete &&
	tmp_files_new &&
	export GIT_SSH=$GIT_FILENAME &&
	echo "test ssh key : $(ssh -o StrictHostKeyChecking=no -i $ID_RSA_FILENAME git@git.maxbet.asia)" &&
	git submodule init &&
	git submodule update &&
	mix local.hex --force &&
	mix local.rebar --force &&
	mix deps.clean --all &&
	mix clean &&
	mix deps.get &&
	mix deps.compile &&
	mix compile.protocols &&
	maybe_check_silverb &&
	mix release &&
	deploy &&
	tmp_files_delete &&
	echo "SUCCESS"
}

# execute
main || cleanup
