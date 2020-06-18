#!/bin/bash
repository_name=$1
tag=$2
images=($(docker images | grep $repository_name | grep $tag | awk '{print $1}'))

for image in "${images[@]}"
do
   docker pull $image:$tag
done
