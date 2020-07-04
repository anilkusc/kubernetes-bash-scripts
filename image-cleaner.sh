#!/bin/bash
none_images_id=($(docker images | grep $1 | grep none | awk '{print $3}'))

for none_image_id in "${none_images_id[@]}"
do
	docker rmi -f none_image_id
done

#!/bin/bash
none_images_id=($(docker images | grep $1 | grep none | awk '{print $3}'))

for none_image_id in "${none_images_id[@]}"
do
#       docker rmi -f $none_image_id
echo "This none image is deleted: " $none_image_id
done

all_images=($(docker images | grep $1 | awk '{print $1}' | xargs -n1 | sort -u | xargs ))

for image in "${all_images[@]}"
do
image_tags=$(docker images | grep $image |  awk '{print $3}' | grep -v latest )
root_tag=${myarr[0]}
for image_tag in "${image_tags[@]}"
do
if [[ $image_tag == $root_tag    ]];then
continue
else
image_id=$(echo $image | grep $image_tag  | awk '{print $3}' )
#$docker rmi -f $same_image_id
echo "this duplicated images are deleted : "  $image  $image_tag  $same_image_id
fi
done
done
