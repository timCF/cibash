#!/bin/bash

# check and prepare args
if [[ $# -ne 3 ]]; then
	echo "need 3 args"
	exit 1
fi
if [[ -z "$YANDEX_TOKEN" ]]; then
	echo "you should set YANDEX_TOKEN variable"
	exit 1
fi
THIS_APP=$1
ERLANG_NODE=$2
RELEASE_MODE=$3
if [[ -z "$TRAVIS_OS_NAME" ]]; then
	RELEASE_FILENAME="$ERLANG_NODE".tar.gz
else
	RELEASE_FILENAME="$ERLANG_NODE"_"$TRAVIS_OS_NAME".tar.gz
fi
if [[ ! $RELEASE_MODE =~ ^(build|rel)$ ]]; then
	echo "bad release mode $RELEASE_MODE"
	exit 1
fi

# define functions

function deploy_upload {
	local UPLOAD_URL=$(curl -H "\"$YANDEX_TOKEN\"" "https://cloud-api.yandex.net/v1/disk/resources/upload?fields=href&overwrite=true&path=%2Felixir_releases%2F$RELEASE_FILENAME" | sed -e 's/^.*"href"[ ]*:[ ]*"//' -e 's/".*//') &&
	curl $UPLOAD_URL --upload-file $RELEASE_FILENAME &&
	rm -rf ./$RELEASE_FILENAME
}

function deploy_build {
	local THIS_DIR=$(basename `pwd`) &&
	cd ..
	if [[ "$THIS_DIR" -ne "$ERLANG_NODE" ]]; then
		rm -rf ./$ERLANG_NODE
		mv ./$THIS_DIR ./$ERLANG_NODE
	fi
	rm -rf ./$RELEASE_FILENAME &&
	tar -zcvf $RELEASE_FILENAME ./$ERLANG_NODE &&
	rm -rf ./$ERLANG_NODE &&
	deploy_upload
}

function deploy_rel {
	local THIS_DIR=$(basename `pwd`) &&
	mix release &&
	cd .. &&
	rm -rf ./$THIS_APP.tar.gz &&
	mv ./$THIS_DIR/rel/$THIS_APP/releases/0.0.1/$THIS_APP.tar.gz ./$THIS_APP.tar.gz &&
	rm -rf ./$THIS_DIR &&
	rm -rf ./$ERLANG_NODE &&
	mkdir ./$ERLANG_NODE &&
	mv ./$THIS_APP.tar.gz ./$ERLANG_NODE/$THIS_APP.tar.gz &&
	cd ./$ERLANG_NODE &&
	tar xvfz $THIS_APP.tar.gz &&
	rm -rf $THIS_APP.tar.gz &&
	sed -i "s/-name\ $THIS_APP@127\.0\.0\.1/-sname\ $ERLANG_NODE/g" ./releases/0.0.1/vm.args &&
	cd .. &&
	tar -zcvf $RELEASE_FILENAME ./$ERLANG_NODE &&
	rm -rf ./$ERLANG_NODE &&
	deploy_upload
}

function deploy {
	local RELEASES_DIR="~/elixir_releases" &&
	if [[ $RELEASE_MODE =~ ^(build)$  ]]; then
		deploy_build
	else
		deploy_rel
	fi
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
	git submodule init &&
	git submodule update &&
	mix local.hex --force &&
	mix local.rebar --force &&
	mix deps.clean --all &&
	mix clean &&
	rm -rf ./_build &&
	rm -rf ./rel &&
	mix deps.get &&
	mix deps.compile &&
	mix compile.protocols &&
	maybe_check_silverb &&
	deploy &&
	echo "SUCCESS"
}

# execute
main || exit 1
