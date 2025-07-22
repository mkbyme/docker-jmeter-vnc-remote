#!/bin/bash
# docker build -t mkbyme/docker-jmeter-vnc-remote:jmeter-5.6.3-ubuntu-24 .
set -e
JMETER_VERSION=${JMETER_VERSION:-"5.6.3"}
IMAGE_TIMEZONE=${IMAGE_TIMEZONE:-"Asia/Ho_Chi_Minh"}
DOCKER_REPO="mkbyme/docker-jmeter-vnc-remote"

echo "Building base Ubuntu 24.04 image..."
docker build -f Dockerfile.base -t "${DOCKER_REPO}:base-ubuntu-2404" .

echo "Building JMeter ${JMETER_VERSION} image with VNC..."
docker build \
    --build-arg JMETER_VERSION=${JMETER_VERSION} \
    --build-arg TZ=${IMAGE_TIMEZONE} \
    -t "${DOCKER_REPO}:${JMETER_VERSION}-ubuntu-2404" \
    .

echo "Build completed successfully!"
echo "Images created:"
echo "  - ${DOCKER_REPO}:base-ubuntu-2404"
echo "  - ${DOCKER_REPO}:${JMETER_VERSION}-ubuntu-2404"
