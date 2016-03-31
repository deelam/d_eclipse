# My dockerfiles
See several docker apps under the "Tags" tab.

# Running as your userid and groupid
I prefer my docker applications run as this user (rather than root) when possible.  To do this, options are:
1. Create a standard user on image, then modify container's user id to match those on host
  * the created user should be in the same group as the application in order to access application files
  * https://chapeau.freevariable.com/2014/08/docker-uid.html
  * Advantage: app can read and write files as appropriate user
    * can run as root or create personalized image to run as user
  * Disadvantage: must modify container's /etc and chown $HOME files every time image is run, unless container is saved as image (in which case just generate a Dockerfile for a given host userid).
2. Install app as root and run image using `-u $UID`.  The groupId is still root, which may be okay since most files don't all group write access (must verify this when creating images).
  * Advantage: app can write files as appropriate user
  * Disadvantage: existing files may not be accessible by $UID
    * unless the user's default groupId is set to host's default groupId and still keep user in the root group (then user will have access to all files).
    * /etc/passwd and /etc/group will not have entries for the host's user


* Typically, my docker images create a `me` user with group `me`.  
* If the application needs read or write access to files on a volume, the 
* Run my docker image with `-v $PWD/container_scripts:/scripts`
* My docker images have an ENTRYPOINT that runs `/scripts/entry.sh`.  If you provide a CMD on the commandline, it will be run after entry.sh using bash's `exec`.  The default CMD depends on the image.  See http://stackoverflow.com/questions/21553353/what-is-the-difference-between-cmd-and-entrypoint-in-a-dockerfile
* A typical `entry.sh` looks like this:```
#!/bin/bash
[ -e host-userinfo.src ] || exit 1
. host-userinfo.src

CONTAINER_USERNAME=me
CONTAINER_GROUPNAME=me
HOMEDIR="/home/$CONTAINER_USERNAME"

# Create group and user to match those of host
groupadd -f -g $DHOST_GROUPID $CONTAINER_GROUPNAME
useradd -u $DHOST_USERID -g $CONTAINER_GROUPNAME $CONTAINER_USERNAME
mkdir --parent $HOMEDIR
chown -R $CONTAINER_USERNAME:$CONTAINER_GROUPNAME $HOMEDIR

#adduser --disabled-password --gecos '' $DHOST_USERNAME
# adduser creates and populates home directory, add group with same name as user, add user to that group, prompts for pwd

# Allow user to sudo  (comment these lines out to disable sudo)
adduser $DHOST_USERNAME sudo
echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

#orig: su -m $DHOST_USERNAME -c exec $@
su -m -l $DHOST_USERNAME -c exec $@
```
* and `host-userinfo.src` can be created using `createSrc.sh`:```
#!/bin/bash
echo "
DHOST_USERNAME=`id -n -u`
DHOST_USERID=`id -u`
DHOST_GROUPID=`id -g`
" > host-userinfo.src
```
* If `/scripts/entry.sh` doesn't exist (because the `/scripts` volume wasn't mounted or the `entry.sh` file wasn't created), then the container will run as root.

# Tips
* http://www.projectatomic.io/docs/docker-image-author-guidance/
* http://crosbymichael.com/dockerfile-best-practices.html
* WebUI (http://linoxide.com/linux-how-to/setup-dockerui-web-interface-docker)
 * : ```docker run -d -p 9000:9000 --privileged -v /var/run/docker.sock:/var/run/docker.sock dockerui/dockerui```
* VPN issues
 * Option 1: Run containers using Docker's 'host' network  ```docker run --net=host ...```
 * Option 2: modify iptables
  * Hack to allow modifying iptables: http://superuser.com/questions/284709/how-to-allow-local-lan-access-while-connected-to-cisco-vpn
  * http://www.petefreitag.com/item/753.cfm
```
## After enabling VPN
sudo iptables -L --line-numbers -n
sudo iptables -D ciscovpn 22

### Modify your container's /etc/resolv.conf to include the host's DNS
domain <yourDomain>
nameserver 192.168.11.1
nameserver <yourVPNsDNS>
```

# Resources and references
* http://dockerfile.github.io/ https://github.com/dockerfile
* https://github.com/jfrazelle/dockerfiles


