#!/bin/bash

# http://olivier.barais.fr/blog/posts/2014.08.26/Eclipse_in_docker_container.html
#xhost +
xhost +localhost
docker run -ti -e DISPLAY=$DISPLAY \
 -v /tmp/.X11-unix:/tmp/.X11-unix \
 -v ~/.m2:/home/dd/.m2 \
 -v ~/dev:/home/dd/dev \
 -v ~/dev/marsWorkspace:/home/dd/workspace \
 "$@" \
 --name eclipseContainer \
 myEclipse

