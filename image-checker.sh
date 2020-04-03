#!/bin/bash
registry="<your-registry-adress>"
username="<your-username>"
password="<your-password>"


##BY this you can append all images from repository to the array
#images=($( echo $(curl -s https://$username:$password@$registry/v2/_catalog | jq .repositories | jq .[])))
##Or you can set manually your image array

#images=( nginx alpine busybox  )
#only images that you specify
images=( $(curl -s https://$username:$password@$registry/v2/_catalog | jq .repositories | jq -r '.[] | select(contains("<common-name>"))') )
#Specify namespaces you do not want to include
environments=($(kubectl get ns --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | grep -v "default\|kube-system\|ingress-nginx\|kube-node-lease\|kube-public\|monitoring"))

for env in "${environments[@]}"
do

echo "-------------"$env "NAMESPACE--------------------"
for image in "${images[@]}"
do
#take image tag by domain name
case $env in
     dev)
          tag="dev"
          ;;
     test | preprod )
          tag="staging"
          ;;
     prod)
          tag="latest"          
esac

file=/imagerecords/"$tag"/"$image".txt
if [ ! -e "$file" ]; then
    echo "$(tput setaf 1)File does not exist: $file $(tput sgr0)"
fi

old_image=$(cat $file)
new_image=$(echo $(curl -s https://"$username":"$password"@"$registry"/v2/"$image"/manifests/"$tag" | jq ."fsLayers" | jq .[]))

if [ "$old_image" == "$new_image" ];
then
echo "image: "$image" is already up-to-date"
else
echo "$(tput setaf 2)image: " $image" is updating$(tput sgr0)"
#match image-name and pod-name
case $image in
     my-image-name)
          podname="my-pod-name"
          ;;
     image-a)
          podname="pod-a"
          ;;
     image-b)
          podname="image-b"
          ;;
     *)
          echo "$(tput setaf 1)this image is not in the update list: " $image" not updating$(tput sgr0)"
          continue
          ;;
esac

echo "Deleting " $podname

kubectl delete pod -n $env $( kubectl get po -n $env | grep $podname | awk '{print $1}' )

echo $new_image > $file

echo "$(tput setaf 2)$podname is updated$(tput sgr0)"

fi
done
done
