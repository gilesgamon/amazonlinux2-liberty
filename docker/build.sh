#!/bin/bash

mkdir -p files/binaries/

# Build IBM Java image
if [ ! -f "files/binaries/ibm-java-x86_64-sdk-8.0-6.6.bin" ] ; then
	echo "fetching IBM's Java"
	curl -o files/binaries/ibm-java-x86_64-sdk-8.0-6.6.bin http://public.dhe.ibm.com/ibmdl/export/pub/systems/cloud/runtimes/java/8.0.6.6/linux/x86_64/ibm-java-x86_64-sdk-8.0-6.6.bin
else
	echo "Already got IBM's Java"
fi

docker build . -f Dockerfile_ibmjdk8 -t ibmjdk:8
retval=$?
if [ $retval -ne 0 ]; then
    echo "Return code was not zero but $retval"
    exit 1
fi

if [ ! -f "files/binaries/wlp-webProfile7-17.0.0.2.zip" ] ; then
	echo "fetching webProfile7"
	curl -o files/binaries/wlp-webProfile7-17.0.0.2.zip https://repo1.maven.org/maven2/com/ibm/websphere/appserver/runtime/wlp-webProfile7/17.0.0.2/wlp-webProfile7-17.0.0.2.zip
else
	echo "Already got webProfile7"
fi

# Build supervisor into image
docker build . --build-arg SOURCE=ibmjdk:8 -f Dockerfile_supervisor -t ibmjdk:latest
retval=$?
if [ $retval -ne 0 ]; then
    echo "Return code was not zero but $retval"
    exit 1
fi

# Build IBM Liberty image
docker build . -f Dockerfile_liberty17 -t liberty:17
retval=$?
if [ $retval -ne 0 ]; then
    echo "Return code was not zero but $retval"
    exit 1
fi

if [ ! -f "files/binaries/ferret-1.0.war" ] ; then
	echo "fetching ferret"
	curl -o files/binaries/ferret-1.0.war https://repo1.maven.org/maven2/net/wasdev/wlp/sample/ferret/1.0/ferret-1.0.war
else
	echo "Already got ferret"
fi

# Build ferret image
docker build . -f Dockerfile_ferret -t ferret:latest
retval=$?
if [ $retval -ne 0 ]; then
    echo "Return code was not zero but $retval"
    exit 1
fi

#if [ ! -f "files/binaries/amazon-cloudwatch-agent.rpm" ] ; then
#	echo "fetching AWS CloudWatch Agent"
#	curl -o files/binaries/amazon-cloudwatch-agent.rpm https://s3.amazonaws.com/amazoncloudwatch-agent/centos/amd64/latest/amazon-cloudwatch-agent.rpm
#else
#	echo "Already got AWS CloudWatch Agent"
#fi

# Build supervisor into image
docker build . --build-arg SOURCE=ferret:latest -f Dockerfile_awslogs -t ferret:awslogs
retval=$?
if [ $retval -ne 0 ]; then
    echo "Return code was not zero but $retval"
    exit 1
fi

# Spin up container with latest ferret image
docker stop ferret
docker rm ferret
docker run -itd -p 9443:9443 -p 9080:9080 --name ferret ferret:awslogs