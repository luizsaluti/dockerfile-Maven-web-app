FROM  alpine/git as git

ADD . /fonte
WORKDIR /fonte

RUN git clone https://luiz_saluti@bitbucket.org/luiz_saluti/primefaces.git

FROM  phusion/baseimage:0.11 as build 

MAINTAINER  Author Name <author@email.com>

RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main universe" > /etc/apt/sources.list

RUN apt-get -y update

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q python-software-properties software-properties-common

ENV JAVA_VER 8
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

RUN echo 'deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main' >> /etc/apt/sources.list && \
    echo 'deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main' >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C2518248EEA14886 && \
    apt-get update && \
    echo oracle-java${JAVA_VER}-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y --force-yes --no-install-recommends oracle-java${JAVA_VER}-installer oracle-java${JAVA_VER}-set-default && \
    apt-get clean && \
    rm -rf /var/cache/oracle-jdk${JAVA_VER}-installer

RUN update-java-alternatives -s java-8-oracle

RUN echo "export JAVA_HOME=/usr/lib/jvm/java-8-oracle" >> ~/.bashrc

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /usr/local/src
RUN wget http://www-us.apache.org/dist/maven/maven-3/3.5.4/binaries/apache-maven-3.5.4-bin.tar.gz
RUN tar -xf apache-maven-3.5.4-bin.tar.gz
RUN mv apache-maven-3.5.4/ apache-maven/

ENV M2_HOME /usr/local/src/apache-maven

ENV MAVEN_HOME /usr/local/src/apache-maven
ENV PATH ${M2_HOME}/bin:${PATH}

ADD . /fonte
WORKDIR /fonte
COPY --from=git /fonte/primefaces /fonte

RUN mvn clean package

FROM jboss/wildfly
ADD . /fonte
WORKDIR /fonte
COPY --from=build /fonte/target/PrimeFacesMockingTest.war /opt/jboss/wildfly/standalone/deployments/

# CMD ["/sbin/my_init"]

# CMD ["bash"]
