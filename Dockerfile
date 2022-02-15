FROM mkbyme/docker-jmeter-vnc-remote:base
#chuyen sang root user https://hub.docker.com/r/consol/ubuntu-xfce-vnc

USER 0
ENV REFRESHED_AT 2022-02-14
#set lai password ve misa default
ENV VNC_PW=12345678@Abc

#############################
### JMETER 
#############################

#jmeter base image #docs: https://github.com/justb4/docker-jmeter
ARG JMETER_VERSION="5.4.3"
ENV JMETER_HOME /opt/apache-jmeter-${JMETER_VERSION}
ENV	JMETER_BIN	${JMETER_HOME}/bin
ENV	JMETER_DOWNLOAD_URL  https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz


# Install extra packages # chromium-browser 
ARG TZ="Asia/Ho_Chi_Minh"
ENV TZ ${TZ}
RUN mkdir -p /tmp/dependencies  \
	&& curl -L --silent ${JMETER_DOWNLOAD_URL} >  /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz  \
	&& mkdir -p /opt  \
	&& tar -xzf /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz -C /opt  \
	&& rm -rf /tmp/dependencies

# TODO: plugins (later)
# && unzip -oq "/tmp/dependencies/JMeterPlugins-*.zip" -d $JMETER_HOME

# Set global PATH such that "jmeter" command is found
ENV PATH $PATH:$JMETER_BIN
#############################
### JMETER END
#############################

#############################
### START UP SCRIPT 
#############################
COPY ./script/vnc_startup.sh /dockerstartup
#############################
### START UP SCRIPT  END
#############################


#tao shortcut
COPY ./jmeter.desktop /headless/Desktop

RUN chmod +x ${JMETER_BIN}/jmeter\ 
    && chmod 777 /srv\ 
    && chmod +x /headless/Desktop/jmeter.desktop\
	&& sed -i -e "s/latest/${JMETER_VERSION}/g" /headless/Desktop/jmeter.desktop

#chuyen ve user default 
USER 1000
