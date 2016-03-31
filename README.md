# d_eclipse  (Docker Eclipse)

Ubuntu 15.10, with jdk8 and Eclipse Mars with Groovy plugin based on https://hub.docker.com/r/leesah/eclipse/

Example usage:
```
docker pull d_eclipse:latest
# download and modify Dockerfile.user to match your userid and optionally any desired username
docker build -t myeclipse -f Dockerfile.user .

xhost +localhost
# assuming username=dd, run the following:
docker run -ti -e DISPLAY=$DISPLAY \
 -v /tmp/.X11-unix:/tmp/.X11-unix \
 -v ~/.m2:/home/dd/.m2 \
 -v ~/dev:/home/dd/dev \
 -v ~/dev/marsWorkspace:/home/dd/workspace \
 "$@" \
 --name eclipseContainer \
 myeclipse

docker start -ai  eclipseContainer
```

# Tips
* WebUI (http://linoxide.com/linux-how-to/setup-dockerui-web-interface-docker)
 * : ```docker run -d -p 9000:9000 --privileged -v /var/run/docker.sock:/var/run/docker.sock dockerui/dockerui```
* VPN issues
 * Option 1: Run containers using Docker's 'host' network  ```docker run --net=host ...```
 * Option 2: modify iptables
  * Hack to allow modifying iptables: http://superuser.com/questions/284709/how-to-allow-local-lan-access-while-connected-to-cisco-vpn
  * http://www.petefreitag.com/item/753.cfm
```
# After enabling VPN
sudo iptables -L --line-numbers -n
sudo iptables -D ciscovpn 22

# Modify your container's /etc/resolv.conf to include the host's DNS
domain <yourDomain>
nameserver 192.168.11.1
nameserver <yourVPNsDNS>
```
