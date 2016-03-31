# My dockerfiles
See several docker apps under the "Tags" tab.

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

# Resources and references
* http://dockerfile.github.io/ https://github.com/dockerfile
* https://github.com/jfrazelle/dockerfiles


