#!/bin/bash

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
