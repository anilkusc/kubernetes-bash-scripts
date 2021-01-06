#!/bin/bash

TOKEN=$(cat /run/secrets/kubernetes.io/serviceaccount/token)

#Get pods

curl -H "Authorization: Bearer $TOKEN" https://kubernetes/api/v1/namespaces/default/pods/ --insecure

#Get sample pod

curl -H "Authorization: Bearer $TOKEN" https://kubernetes/api/v1/namespaces/default/pods/pod-demo-sa-7f974c5849-4ckrt/status --insecure

#Delete pod

#curl -x DELETE -H "Authorization: Bearer $TOKEN" https://kubernetes/apis/apps/v1/namespaces/default/deployments/pod-demo-sa/status --insecure
#curl -H "Authorization: Bearer $TOKEN" https://kubernetes/api/v1/namespaces/{namespace}/pods/{name}/log --insecure
#curl -X PATCH -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/strategic-merge-patch+json' --data '{"spec":{"replias":1}}' 'https://kubernetes/apis/apps/v1/namespaces/default/deployments/test' --insecure
