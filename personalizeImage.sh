#!/bin/bash

APPNAME=${1:-eclipse}

[ -d "$APPNAME" ] || exit 1
cd $APPNAME || exit 2

export ORIG_IMAGE=${2:-d_eclipse:isuper3}
export ENABLE_SUDO=${3:-true}
export HOST_USERID=`id -u`
export HOST_USERNAME=`id -n -u`
export APPENDED_ACTIONS=${4:-"RUN chmod -R 775 /usr/local/eclipse && chgrp -R users /usr/local/eclipse 

COPY lifecycle-mapping-metadata.xml /home/${HOST_USERNAME}"}


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

replaceCurlyBaredVariables < Dockerfile.user.tmpl > "Dockerfile.$HOST_USERNAME.$HOST_USERID"

#docker build -t personalized/$APPNAME -f "Dockerfile.$HOST_USERNAME.$HOST_USERID" .

#docker run -ti --rm personalized/$APPNAME bash





