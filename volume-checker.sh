#!/bin/bash
volume_directory=/volumes/replicas
volume_count="$(ls $volume_directory | wc -l )"

for (( i=1; i<$volume_count+1 ; i++ ))
do

size=$(du -h /volumes/replicas/"$(ls /volumes/replicas/ |  head -n $i | tail -n 1)" | awk '{print $1}' | sed 's/G//g' |  sed 's/\..*//g' )
if [[ $size -ge 90 ]]; then
echo "mail atılıyor"
printf "To:anilkuscu95@gmail.com\nFrom:alertmanager@gmail.com\nSubject: Volume Size Alarm.\n\n\n\n\n there is a volume that size is bigger than 90 Gi." > mail.txt
ssmtp anilkuscu95@gmail.com < mail.txt
else
echo "Volume size is : " $size
fi
done
