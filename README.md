# dockers

Ubuntu 15.10, with jdk8 and Eclipse Mars with Groovy plugin based on https://hub.docker.com/r/leesah/eclipse/

Example usage:
```
docker pull d_eclipse:latest .
# download and modify Dockerfile.user to match your userid and optionally any desired username
docker build -t myEclipse -f Dockerfile.user .

xhost +localhost
# assuming username=dd, run the following:
docker run -ti -e DISPLAY=$DISPLAY \
 -v /tmp/.X11-unix:/tmp/.X11-unix \
 -v ~/.m2:/home/dd/.m2 \
 -v ~/dev:/home/dd/dev \
 -v ~/dev/marsWorkspace:/home/dd/workspace \
 "$@" \
 --name eclipseContainer \
 myEclipse

docker start -ai  eclipseContainer
```

# Tips
* WebUI (http://linoxide.com/linux-how-to/setup-dockerui-web-interface-docker)
 * : ```docker run -d -p 9000:9000 --privileged -v /var/run/docker.sock:/var/run/docker.sock dockerui/dockerui```
