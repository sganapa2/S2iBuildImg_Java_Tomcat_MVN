FROM openshift/base-centos7

EXPOSE 8080

ENV JAVA_VERSON 1.8.0
ENV MAVEN_VERSION 3.3.9

ENV TOMCAT_MAJOR_VERSION 8 
ENV TOMCAT_MINOR_VERSION 8.0.32 
ENV CATALINA_HOME /tomcat



LABEL io.k8s.description="Platform for building and running Spring Boot applications" \
      io.k8s.display-name="Spring Boot Maven 3" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,java,java8,maven,maven3,springboot"

COPY s2i/bin/assemble /opt/app-root/s2i/bin/
COPY s2i/bin/run /opt/app-root/s2i/bin/
LABEL io.openshift.s2i.scripts-url="image:///opt/app-root/s2i/bin/"
RUN chown -R 1001:0 /opt/app-root/


RUN  yum install -y java-$JAVA_VERSON-openjdk java-$JAVA_VERSON-openjdk-devel
#  yum install -y curl && \
#  yum clean all

RUN yum install -y curl

RUN curl -fsSL https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
  && mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV JAVA_HOME /usr/lib/jvm/java
ENV MAVEN_HOME /usr/share/maven

# Add configuration files, bashrc and other tweaks
# COPY ./s2i/bin/ $STI_SCRIPTS_PATH

RUN chown -R 1001:0 ./

WORKDIR /

RUN wget -q -e use_proxy=yes https://archive.apache.org/dist/tomcat/tomcat-8/v8.0.32/bin/apache-tomcat-8.0.32.tar.gz && \
    tar -zxf apache-tomcat-*.tar.gz &&\
    rm -f apache-tomcat-*.tar.gz && \
    mv apache-tomcat* tomcat 


ENV JAVA_OPTS="-Dtuf.environment=DEV -Dtuf.appFiles.rootDirectory=/TempDirRoot" 

RUN groupadd -r safe 
RUN useradd  -r -g safe safe 
RUN mkdir -p /tomcat/webapps /TempDirRoot
RUN chown -R 1001:1001 /tomcat /TempDirRoot 
RUN chmod -R 777 /tomcat /TempDirRoot 

RUN cd /tomcat/webapps/; rm -rf ROOT docs examples host-manager manager 

USER 1001

EXPOSE 8080
