# docker build -t jdk8eclipse:groovy .
# docker tag jdk8eclipse:groovy deelam/eclipse:groovy

# Ubuntu 15.10, with jdk8 and Eclipse Mars with Groovy plugin
# based on https://hub.docker.com/r/leesah/eclipse/~/dockerfile/

# WebUI: http://linoxide.com/linux-how-to/setup-dockerui-web-interface-docker/
#  docker run -d -p 9000:9000 --privileged -v /var/run/docker.sock:/var/run/docker.sock dockerui/dockerui

FROM ubuntu:15.10 

MAINTAINER dnaelam@gmail.com

ENV ECLIPSE_DOWNLOAD=http://download.eclipse.org/technology/epp/downloads/release/mars/2/eclipse-java-mars-2-linux-gtk-x86_64.tar.gz 
ENV MAVEN_DOWNLOAD=http://apache.osuosl.org/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz

RUN apt-get update \
 && apt-get install -y software-properties-common curl sudo iputils-ping net-tools vim \
\
 && apt-add-repository -y ppa:webupd8team/java \
 && apt-get update \
 && echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections \
 && echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections \
 && apt-get install -y oracle-java8-set-default libgtk2.0-0 libxtst6 \
\
 && curl "$ECLIPSE_DOWNLOAD" | tar vxz -C /usr/local \
 && chmod -R 775 /usr/local/eclipse \
 && ln -s /usr/local/eclipse/eclipse /usr/local/bin/

RUN /usr/local/eclipse/eclipse -nosplash -application org.eclipse.equinox.p2.director -repository http://dist.springsource.org/snapshot/GRECLIPSE/e4.5/ -installIU org.codehaus.groovy.eclipse.feature.feature.group \
\
 && curl https://projectlombok.org/downloads/lombok.jar > lombok.jar \
 && /usr/bin/java -jar lombok.jar install auto \
 && chown root:users /usr/local/eclipse/lombok.jar \
 && chmod 775        /usr/local/eclipse/lombok.jar \
\
 && mkdir -p /usr/share/maven \
 && curl -fsSL "$MAVEN_DOWNLOAD" | tar -xzC /usr/share/maven --strip-components=1 \
 && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn \
\
 && apt-get --purge autoremove -y \
 && apt-get clean

ENV MAVEN_HOME /usr/share/maven

