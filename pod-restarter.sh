#!/bin/bash
#specify exclude namespaces
environment=($(kubectl get ns --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | grep -v "default\|kube-system\|ingress-nginx\|kube-node-lease\|kube-public\|monitoring"))

for env in "${environment[@]}"
do
pods=( my-pod )
for pod in "${pods[@]}"
do
kubectl delete pod -n $env $(kubectl get pod -n $env | grep $pod | awk '{print $1}')
done
done
