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

APPNAME="${1%%/*}"
[ "$APPNAME" ] || { echo "Usage: personalizeImage <appname>"; exit 1; }
[ -d "$APPNAME" ] || mkdir "$APPNAME" || exit 2

FROM_IMAGE=`grep IMAGETAG $APPNAME/Dockerfile | cut -d' ' -f3`
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
	echo "To build your image: docker build -t personalized/$APPNAME -f \"$DOCKERFILE\" $APPNAME"
	echo "To run your image:   docker run -ti --rm personalized/$APPNAME bash"
fi








