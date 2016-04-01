#!/bin/bash

replaceCurlyBaredVariables(){
	# Copied from http://stackoverflow.com/questions/2914220/bash-templating-how-to-build-configuration-files-from-templates-with-bash
	while read -r line ; do
		 while [[ "$line" =~ (\$\{[a-zA-Z_][a-zA-Z_0-9]*\}) ]] ; do
			  LHS=${BASH_REMATCH[1]}
			  RHS="$(eval echo "\"$LHS\"")"
			  line=${line//$LHS/$RHS}
		 done
		 echo "$line"
	done
}

createBaseImage(){
	APPNAME="${1%%/*}"
	[ "$APPNAME" ] || { echo "Usage: createMyImage <appname>"; exit 1; }
	[ -d "$APPNAME" ] || mkdir "$APPNAME" || exit 2

	[ -f "$APPNAME/Dockerfile" ] && FROM_IMAGE=`grep IMAGETAG $APPNAME/Dockerfile | cut -d' ' -f3`
	: ${FROM_IMAGE:=deelam/dockerfiles:$APPNAME}

	docker build -t "$FROM_IMAGE" $APPNAME
}

createMyDockerfile(){
	APPNAME="${1%%/*}"
	[ "$APPNAME" ] || { echo "Usage: createMyDockerfile <appname>"; exit 1; }
	[ -d "$APPNAME" ] || mkdir "$APPNAME" || exit 2

	[ -f "$APPNAME/Dockerfile" ] && FROM_IMAGE=`grep IMAGETAG $APPNAME/Dockerfile | cut -d' ' -f3`
	: ${FROM_IMAGE:=deelam/dockerfiles:$APPNAME}

	: ${ENABLE_SUDO:=true}
	HOST_USERID=`id -u`
	HOST_USERNAME=`id -n -u`

	if [ -f "$APPNAME/personalizedActions.src" ]; then
		. "$APPNAME/personalizedActions.src"
	else
		echo "TODO: retrieve $APPNAME/personalizedActions.src"
		echo "# These variables are used to replace variables in Dockerfile.user.tmpl
	PREPENDED_ACTIONS=\"\"
	APPENDED_ACTIONS=\"\"
	USER_ACTIONS=\"\"
	ENABLE_SUDO=true
	" > "$APPNAME/personalizedActions.src"
	fi

	DOCKERFILE="$APPNAME/Dockerfile.$HOST_USERNAME.$HOST_USERID"
	if [ -e "$DOCKERFILE" ]; then
		echo "File already exists: $DOCKERFILE  ---   Move existing file and rerun."
	else
		echo "Creating file: $DOCKERFILE   ---  Modify this to your hearts content."
		replaceCurlyBaredVariables < Dockerfile.user.tmpl > "$DOCKERFILE"
	fi
}

buildMyImage(){
	APPNAME="${1%%/*}"
	[ "$APPNAME" ] || { echo "Usage: buildMyImage <appname>"; exit 1; }

	HOST_USERID=`id -u`
	HOST_USERNAME=`id -n -u`
	DOCKERFILE="$APPNAME/Dockerfile.$HOST_USERNAME.$HOST_USERID"
	docker build -t personalized/$APPNAME -f "$DOCKERFILE" $APPNAME
}

runMyImageBash(){
	APPNAME="${1%%/*}"
	[ "$APPNAME" ] || { echo "Usage: runMyImageBash <appname>"; exit 1; }
	CONTNAME="${2:-$APPNAME-instance}"
	docker run --name "$CONTNAME"  -ti personalized/$APPNAME bash
}

restartContainer(){
	APPNAME="${1%%/*}"
	[ "$APPNAME" ] || { echo "Usage: restartContainer <appname>"; exit 1; }
	CONTNAME="${2:-$APPNAME-instance}"
	docker start -ai "$CONTNAME"
}

[ "$1" ] || { echo "
Usage: $0 [base|init|build] <appname>
       $0 [runBash|run|restart] <appname> [containername]
  Default containername=appname-instance
"; exit 1; }
CMD=$1
shift
case "$CMD" in
  base) createBaseImage $1 ;;
  init) createMyDockerfile $1 ;;
  build) buildMyImage $1 ;;
  runBash) runMyImageBash $1 $2 ;;
  restart) restartContainer $1 $2 ;;
esac


