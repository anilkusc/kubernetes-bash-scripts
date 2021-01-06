#!/bin/bash
NAMESPACE=$1
DOCKER_SERVER=$2
DOCKER_MAIL=$3
DOCKER_USERNAME=$4
DOCKER_PASSWORD=$5
SECRET_NAME=$6
if [[ $SECRET_NAME == "" ]];then
SECRET_NAME=regcred
fi

kubectl create secret -n $NAMESPACE docker-registry $SECRET_NAME  --docker-server $DOCKER_SERVER  --docker-email $DOCKER_MAIL --docker-username $DOCKER_USERNAME  --docker-password $DOCKER_PASSWORD
#After that you can use this secret for pulling your private image to kubernetes
#imagePullSecrets:
#- name: regcred
