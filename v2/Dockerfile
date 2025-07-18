# Stage 1: Download and extract JMeter
FROM alpine:3.19 AS jmeter-download

# Define JMeter version and URLs
ARG JMETER_VERSION="5.6.3"
ENV JMETER_HOME=/opt/apache-jmeter-${JMETER_VERSION}
ENV JMETER_BIN=${JMETER_HOME}/bin
ENV JMETER_DOWNLOAD_URL=https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz
ENV JMETER_PLUGIN_MANAGER_URL=https://jmeter-plugins.org/get/

# Download and extract JMeter
RUN mkdir -p /tmp/dependencies /opt && \
    cd /tmp/dependencies && \
    wget -q ${JMETER_DOWNLOAD_URL} -O apache-jmeter-${JMETER_VERSION}.tgz && \
    tar -xzf apache-jmeter-${JMETER_VERSION}.tgz -C /opt && \
    wget -q ${JMETER_PLUGIN_MANAGER_URL} -O ${JMETER_HOME}/lib/ext/jmeter-plugin-manager.jar && \
    find ${JMETER_BIN} -type f -name "*.sh" -exec chmod +x {} \; && \
    chmod a+x ${JMETER_BIN}/jmeter

# Stage 2: Final image
FROM mkbyme/docker-jmeter-vnc-remote:base-ubuntu-2404

USER 0
ENV REFRESHED_AT=2025-07-16
ENV VNC_PW=12345678@Abc

# JMeter environment variables
ARG JMETER_VERSION="5.6.3"
ENV JMETER_HOME=/opt/apache-jmeter-${JMETER_VERSION}
ENV JMETER_BIN=${JMETER_HOME}/bin
ENV PATH=$PATH:$JMETER_BIN

# Copy JMeter and set ownership in one layer
COPY --chown=1000:1000 --from=jmeter-download ${JMETER_HOME} ${JMETER_HOME}
RUN cat > /headless/Desktop/jmeter.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Jmeter UI
Comment=Khởi chạy JMeter UI
Exec=/opt/apache-jmeter-${JMETER_VERSION}/bin/jmeter
Icon=/opt/apache-jmeter-${JMETER_VERSION}/docs/images/favicon.png
Path=/srv
Terminal=false
StartupNotify=false
EOF
RUN chown 1000:1000 /headless/Desktop/*.desktop && \
    chmod +x /headless/Desktop/*.desktop

USER 1000
