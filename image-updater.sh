#!/bin/bash
##Specify and pull images
#images=( nginx alpine busybox )
##INclude and exclude images
#images=( $(docker images | grep myimage | grep -v dev | grep -v staging | grep -v none | awk '{print $1}' ) )
##update all images
images=( $(docker images | awk '{print $1}' ) )
for image in "${images[@]}"
do
docker pull $image
done
