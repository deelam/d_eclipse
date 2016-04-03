# Ubuntu 15.10, with jdk8 and Eclipse Mars with Groovy plugin
# based on https://hub.docker.com/r/leesah/eclipse/~/dockerfile/

#FROM ubuntu:15.10 
FROM phusion/baseimage:latest

MAINTAINER deelam

ENV ECLIPSE_DOWNLOAD=http://download.eclipse.org/technology/epp/downloads/release/mars/2/eclipse-java-mars-2-linux-gtk-x86_64.tar.gz 
ENV MAVEN_DOWNLOAD=http://apache.osuosl.org/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz

# 300MB smaller layer (adapted from https://hub.docker.com/r/isuper/java-oracle/~/dockerfile/)
ENV DEBIAN_FRONTEND noninteractive 
ENV VERSION 8 
ENV UPDATE 74 
ENV BUILD 02 
ENV JAVA_HOME /usr/lib/jvm/java-${VERSION}-oracle 

# apt-get install -y iputils-ping net-tools vim

RUN apt-get update && \
   apt-get install -y software-properties-common curl sudo && \
   apt-get install ca-certificates \
        libgtk2.0-0 libxtst6 \
        gcc libc6-dev libssl-dev make \
        -y --no-install-recommends && \
	curl --silent --location --retry 3 --cacert /etc/ssl/certs/GeoTrust_Global_CA.pem \
	--header "Cookie: oraclelicense=accept-securebackup-cookie;" \
	http://download.oracle.com/otn-pub/java/jdk/"${VERSION}"u"${UPDATE}"-b"${BUILD}"/server-jre-"${VERSION}"u"${UPDATE}"-linux-x64.tar.gz \
	| tar xz -C /tmp && \
	mkdir -p /usr/lib/jvm && mv /tmp/jdk1.${VERSION}.0_${UPDATE} "${JAVA_HOME}" && \
	curl --silent --location --retry 3 --cacert /etc/ssl/certs/GlobalSign_Root_CA.pem \
        https://www.openssl.org/source/openssl-1.0.2g.tar.gz \
        | tar xz -C /tmp && \
        cd /tmp/openssl-* && \
                ./config --prefix=/usr && \
                make clean && make && make install && \
        apt-get remove --purge --auto-remove -y \
                gcc \
                libc6-dev \
                libssl-dev \
                make && \
	apt-get autoclean && apt-get --purge -y autoremove && apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN update-alternatives --install "/usr/bin/java" "java" "${JAVA_HOME}/bin/java" 1 && \
	update-alternatives --install "/usr/bin/javac" "javac" "${JAVA_HOME}/bin/javac" 1 && \
	update-alternatives --set java "${JAVA_HOME}/bin/java" && \
	update-alternatives --set javac "${JAVA_HOME}/bin/javac"

# === Creates larger docker layer 
# RUN apt-add-repository -y ppa:webupd8team/java \
#  && apt-get update \
#  && echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections \
#  && echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections \
#  && apt-get install -y oracle-java8-set-default libgtk2.0-0 libxtst6 \
# \
#  && apt-get --purge autoremove -y \
#  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


RUN curl "$ECLIPSE_DOWNLOAD" | tar vxz -C /usr/local \
 && ln -s /usr/local/eclipse/eclipse /usr/local/bin/ \
\
 && /usr/local/eclipse/eclipse -nosplash -application org.eclipse.equinox.p2.director -repository http://dist.springsource.org/snapshot/GRECLIPSE/e4.5/ -installIU org.codehaus.groovy.eclipse.feature.feature.group \
\
 && curl https://projectlombok.org/downloads/lombok.jar > lombok.jar \
 && /usr/bin/java -jar lombok.jar install auto \
 && chown root:users /usr/local/eclipse/lombok.jar \
 && chmod -R 775 /usr/local/eclipse && chgrp -R users /usr/local/eclipse \
\
 && mkdir -p /usr/share/maven \
 && curl -fsSL "$MAVEN_DOWNLOAD" | tar -xzC /usr/share/maven --strip-components=1 \
 && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

COPY lifecycle-mapping-metadata.xml /usr/local/eclipse

ENV MAVEN_HOME /usr/share/maven

# Use baseimage-docker's init system.
# CMD ["/sbin/my_init"]
CMD ["eclipse"]

