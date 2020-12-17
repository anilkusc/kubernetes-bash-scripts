#!/bin/bash

#apt-get update && apt-get install curl -y
#curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
#chmod +x ./kubectl
#mv ./kubectl /usr/local/bin/kubectl

NAMESPACE=$1

if [[ $NAMESPACE == "" ]];then
NAMESPACE=default
fi

CRONJOBS=( $( kubectl get cj -n $NAMESPACE | awk '{print $1}' | grep -v NAME  ) )

for cronjob in ${CRONJOBS[@]}
do
MISSED=$( kubectl describe cj -n $NAMESPACE $cronjob | grep "Cannot determine if job needs to be started")
if [[ $MISSED == "" ]];then
:
else
echo $cronjob
kubectl apply view-last-applied cj -n $NAMESPACE $cronjob > test.yaml
kubectl delete cj -n $NAMESPACE $cronjob
kubectl apply -f test.yaml
fi
done
rm test.yaml
