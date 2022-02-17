#!/bin/bash

if [ $# != 1 ];
then
  echo "Usage: bash ContainerRem.sh imagename"
  echo "Where imagename can be 'fedora', 'ubuntu1804', or 'ubuntu2004'."
  exit
fi

if [ $1 = "fedora" ];
then
  NON_REMEDIATED="fedora_non_remediated"
  REMEDIATED_CONTAINER="fedora_remediated_container"
  SDS="ssg-fedora-ds.xml"
  REMEDIATED_IMAGE="fedora_remediated_image"
fi

if [ $1 = "ubuntu1804" ];
then
  NON_REMEDIATED="bionic_non_remediated"
  REMEDIATED_CONTAINER="bionic_remediated_container"
  SDS="ssg-ubuntu1804-ds.xml"
  REMEDIATED_IMAGE="bionic_remediated_image"
fi

if [ $1 = "ubuntu2004" ];
then
  NON_REMEDIATED="focal_non_remediated"
  REMEDIATED_CONTAINER="focal_remediated_container"
  SDS="ssg-ubuntu2004-ds.xml"
  REMEDIATED_IMAGE="focal_remediated_image"
fi

cd "$1"

# Build fedora image with scanner
podman build -t $NON_REMEDIATED .
# ...installing openscap takes a while

# Run oscap remediation
podman run --name $REMEDIATED_CONTAINER $NON_REMEDIATED oscap xccdf eval --remediate --profile standard --report report.html $SDS

# Copy report to host
podman cp $REMEDIATED_CONTAINER:report.html remediated-report.html

# Create remediated image
podman commit $REMEDIATED_CONTAINER $REMEDIATED_IMAGE

# Remove container
podman rm $REMEDIATED_CONTAINER






