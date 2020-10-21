#!/bin/bash

#If you can reach /var/lib/rancher/longhorn/replicas directory copy replica directory from crushed system to your new system.On new system you need only docker installed.
#Start below command.Name whatever you want and volume-path to your new replica location.volume size should fit your actual volume size.
#docker run -it -v /dev:/host/dev -v /proc:/host/proc -v <volume-path>:/volume --privileged rancher/longhorn-engine:v0.4.1 launch-simple-longhorn <volume-name> <volume-size>
#Here is my example docker command:
#docker run -it -v /dev:/host/dev -v /proc:/host/proc -v /volume/pvc-ce9ca6d1-5466-49b7-8ff2-fc35a6e81422-20b340e3:/volume --privileged rancher/longhorn-engine:v0.6.2 launch-simple-longhorn test 2g
#After container created succesfully you can see your device on /dev/longhorn directory.(It's name is test on my example)
#-After that mount the device to a directory:
#mount /dev/longhorn/test /mnt
#-Now you can reach your files inside /mnt directory.

VOLUME_NAME=$1
VOLUME_SIZE=$2
REPLICA_NAME=$3
LONGHORN_ENGINE=$4
docker run -it -v /dev:/host/dev -v /proc:/host/proc -v /volume/$REPLICA_NAME:/volume --privileged rancher/$LONGHORN_ENGINE launch-simple-longhorn $VOLUME_NAME $VOLUME_SIZE
