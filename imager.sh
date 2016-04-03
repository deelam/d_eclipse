#!/bin/bash

DK_HOME="$HOME/docker/dockerfiles"

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
	[ -d "$DK_HOME/$APPNAME" ] || mkdir "$DK_HOME/$APPNAME" || exit 2

	[ -f "$DK_HOME/$APPNAME/Dockerfile" ] && FROM_IMAGE=`grep IMAGETAG $DK_HOME/$APPNAME/Dockerfile | cut -d' ' -f3`
	: ${FROM_IMAGE:=deelam/dockerfiles:$APPNAME}

	echo Executing: docker build -t "$FROM_IMAGE" $DK_HOME/$APPNAME
	docker build -t "$FROM_IMAGE" $DK_HOME/$APPNAME
}

createMyDockerfile(){
	APPNAME="${1%%/*}"
	[ "$APPNAME" ] || { echo "Usage: createMyDockerfile <appname>"; exit 1; }
	[ -d "$DK_HOME/$APPNAME" ] || mkdir "$DK_HOME/$APPNAME" || exit 2

	[ -f "$DK_HOME/$APPNAME/Dockerfile" ] && FROM_IMAGE=`grep IMAGETAG $DK_HOME/$APPNAME/Dockerfile | cut -d' ' -f3`
	: ${FROM_IMAGE:=deelam/dockerfiles:$APPNAME}

	: ${ENABLE_SUDO:=true}
	HOST_USERID=`id -u`
	HOST_USERNAME=`id -n -u`

	if [ -f "$DK_HOME/$APPNAME/personalizedActions.src" ]; then
		. "$DK_HOME/$APPNAME/personalizedActions.src"
	else
		echo "TODO: retrieve $APPNAME/personalizedActions.src"
		echo "# These variables are used to replace variables in Dockerfile.user.tmpl
	PREPENDED_ACTIONS=\"\"
	APPENDED_ACTIONS=\"\"
	USER_ACTIONS=\"\"
	ENABLE_SUDO=true
	" > "$DK_HOME/$APPNAME/personalizedActions.src"
	fi

	DOCKERFILE="$DK_HOME/$APPNAME/Dockerfile.$HOST_USERNAME.$HOST_USERID"
	if [ -e "$DOCKERFILE" ]; then
		echo "File already exists: $DOCKERFILE  ---   Move existing file and rerun."
	else
		echo "Creating file: $DOCKERFILE   ---  Modify this to your hearts content."
		replaceCurlyBaredVariables < $DK_HOME/Dockerfile.user.tmpl > "$DOCKERFILE"
	fi
}

buildMyImage(){
	APPNAME="${1%%/*}"
	[ "$APPNAME" ] || { echo "Usage: buildMyImage <appname>"; exit 1; }

	HOST_USERID=`id -u`
	HOST_USERNAME=`id -n -u`
	DOCKERFILE="$DK_HOME/$APPNAME/Dockerfile.$HOST_USERNAME.$HOST_USERID"
	echo Executing: docker build -t personalized/$APPNAME -f "$DOCKERFILE" $DK_HOME/$APPNAME
	docker build -t personalized/$APPNAME -f "$DOCKERFILE" $DK_HOME/$APPNAME
}

runMyImage(){
	APPNAME="${1%%/*}"
	[ "$APPNAME" ] || { echo "Usage: runMyImage <appname> [runmode] [containername]"; exit 1; }
	CONTNAME="${3:-$APPNAME-instance}"

	if [ -e "$DK_HOME/$APPNAME/runArgs.src" ]; then
		. "$DK_HOME/$APPNAME/runArgs.src"
	else
		echo "Creating: $DK_HOME/$APPNAME/runArgs.src"
		echo "# These variables are used when running an image
	RUN_MODE=\"\"
	PRERUN_CMDS=\"\"
	DK_RUN_ARGS=\"\"
	" > "$DK_HOME/$APPNAME/runArgs.src"
	fi
	: ${RUN_MODE:=$2}
	: ${AUTO_RESUME:="true"}

	if [ "$AUTO_RESUME" ] && container_exists "$CONTNAME"; then
		echo "Found existing container $CONTNAME ... Resuming"
		resumeContainer "$CONTNAME" $RUN_MODE
		return 
	fi

	set -v
	case "$RUN_MODE" in
		bash)	exec docker run --name "$CONTNAME" -ti $DK_RUN_ARGS \
				personalized/$APPNAME bash ;;
		console)	exec docker run --name "$CONTNAME" -ti $DK_RUN_ARGS \
				personalized/$APPNAME ;;
		gui)	xhost +local:
			eval $PRERUN_CMDS
			eval exec docker run --name "$CONTNAME" $DK_RUN_ARGS \
				--env DISPLAY="$DISPLAY" \
				--volume /tmp/.X11-unix:/tmp/.X11-unix \
				--env PULSE_SERVER="unix:/tmp/pulse-unix" \
				--volume /run/user/$UID/pulse/native:/tmp/pulse-unix \
				personalized/$APPNAME ;;
		*) echo "Unspecified RUN_MODE=$RUN_MODE" ;;
	esac
}

container_exists() {
	local container_name="$1"
	docker ps -a | awk '$NF=="'"${container_name}"'"{found=1} END{if(!found){exit 1}}'
}

resumeContainer(){
	NAME="${1%%/*}"
	[ "$NAME" ] || { echo "Usage: restartContainer <appname|containername> [runmode]"; exit 1; }
	: ${RUN_MODE:=$2}

	if container_exists $NAME; then
		 CONTNAME="$NAME"
	else
		: ${CONTNAME:=$NAME-instance}
	fi

	case "$RUN_MODE" in
		bash|console)	
			echo Executing: docker start -ai "$CONTNAME"
			exec docker start -ai "$CONTNAME"
			;;
		gui)	xhost +local:
			echo Executing: docker start -a "$CONTNAME"
			exec docker start -a "$CONTNAME"
			;;
		*) echo "Unspecified RUN_MODE=$RUN_MODE" ;;
	esac
}

[ "$1" ] || { echo "
Usage: $0 <init|build> <appname>
       $0 run <appname> [bash|console|gui] [containername]
       $0 restart <appname|containername>
  Default containername=appname-instance
"; exit 1; }
CMD=$1
shift
case "$CMD" in
  init) createBaseImage $1 && createMyDockerfile $1 ;;
  build) buildMyImage $1 ;;
  restart) resumeContainer $1 ;;
  run) runMyImage $1 $2 $3 ;;
  *) runMyImage $CMD $1 $2 $3 ;;
esac


