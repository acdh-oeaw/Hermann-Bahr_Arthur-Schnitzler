# START STAGE 1
FROM openjdk:8

LABEL ID=10694 

USER root

ENV ANT_VERSION 1.10.11

ENV ANT_HOME /etc/ant-${ANT_VERSION}

WORKDIR /tmp

RUN wget https://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz --no-check-certificate \
    && mkdir ant-${ANT_VERSION} \
    && tar -zxvf apache-ant-${ANT_VERSION}-bin.tar.gz \
    && mv apache-ant-${ANT_VERSION} ${ANT_HOME} \
    && rm apache-ant-${ANT_VERSION}-bin.tar.gz \
    && rm -rf ant-${ANT_VERSION} \
    && rm -rf ${ANT_HOME}/manual \
    && unset ANT_VERSION

ENV PATH ${PATH}:${ANT_HOME}/bin

WORKDIR /home/hbas-app
COPY . .
RUN  ant

# START STAGE 2
FROM acdhch/existdb:5.2.0-java11-ShenGC

COPY --from=0 /home/hbas-app/build/*.xar /exist/autodeploy

EXPOSE 8080 8443

RUN [ "java", \
    "org.exist.start.Main", "client", "-l", \
    "--no-gui",  "--xpath", "system:get-version()" ]

CMD [ "java", "org.exist.start.Main", "jetty" ]
