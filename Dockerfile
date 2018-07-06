FROM ubuntu

MAINTAINER Leonardo Soto, https://github.com/lsoton

RUN apt-get update && \
    apt-get install -y software-properties-common && \
    apt-get install -y net-tools && \
    apt-get install -y zip unzip curl lynx && \
	apt-get update

# Instalar Java.
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer
	
# Define  directorio.
WORKDIR /data

# Define variable JAVA_HOME
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle


ENV CATALINA_HOME /opt/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p "$CATALINA_HOME"
WORKDIR $CATALINA_HOME

ENV TOMCAT_MAJOR 9
ENV TOMCAT_VERSION 9.0.10
ENV TOMCAT_TGZ_URL https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz


RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.3/gosu-amd64" \
        && chmod +x /usr/local/bin/gosu

RUN set -x \
	&& curl -fSL "$TOMCAT_TGZ_URL" -o tomcat.tar.gz \
#	&& curl -fSL "$TOMCAT_TGZ_URL.asc" -o tomcat.tar.gz.asc \
#	&& gpg --verify tomcat.tar.gz.asc \
	&& tar -xvf tomcat.tar.gz --strip-components=1 \
	&& rm bin/*.bat \
	&& rm tomcat.tar.gz*

RUN cp $CATALINA_HOME/conf/tomcat-users.xml $CATALINA_HOME/conf/tomcat-users.org.xml
RUN sed 's?.*/tomcat-users>.*?<role rolename="manager-gui"/>\n <role rolename="admin-gui"/> \n <user username="admin" password="admin" roles="admin-gui, manager-gui"/> \n\n&?' $CATALINA_HOME/conf/tomcat-users.xml > $CATALINA_HOME/conf/tomcat-users.new.xml
RUN mv $CATALINA_HOME/conf/tomcat-users.new.xml $CATALINA_HOME/conf/tomcat-users.xml

WORKDIR $CATALINA_HOME/bin

EXPOSE 8080 8443 80 443
CMD ["/opt/tomcat/bin/catalina.sh", "run"]
