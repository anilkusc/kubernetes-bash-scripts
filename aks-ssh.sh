#!/bin/bash
set -e 

all_env=( dev staging production )

for env in "${all_env[@]}"
do
   nmspc=$( kubectl get ns | grep $env )
   if [[ nmspc == "" ]];then
        continue
   else:
        namespace=$env
        break
   fi
done

case $namespace in

  "dev")
    resource_group=<your-aks-resource-group-name>
    ;;

  "staging")
     resource_group=<your-aks-resource-group-name>
    ;;

  "production")
    resource_group=<your-aks-resource-group-name>
    ;;

  *)
    echo -n "unknown"
    ;;
esac

node=$( kubectl get nodes | awk '{print $1}'  )

az vm user update --resource-group $resource_group --name $node --username <username> --ssh-key-value ~/.ssh/id_rsa.pub

pod_name=$(kubectl get po | grep ssh | head -n 1 | awk '{print $1}' )
node_ip=$( kubectl get nodes -o wide | awk '{print $6}' | tail -n 1 )

kubectl cp ~/.ssh/id_rsa $pod_name:/id_rsa

command="ssh -i /id_rsa <username>@$node_ip"
install="apk add openssh "
kubectl exec -it $pod_name $install
#kubectl exec -it $pod_name $command
#ssh -i /id_rsa <username>@10.240.0.4
