#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install java dependencies"
apt-get update
apt-get install -y --no-install-recommends openjdk-17-jre ca-certificates-java

# Set JAVA_HOME and update alternatives
export JAVA_HOME="$(dirname $(dirname $(readlink -f $(which java))))"
update-alternatives --set java $(readlink -f $(which java))
echo "JAVA_HOME set to $JAVA_HOME"
