#!/bin/bash
#Specify namespaces that you don't want to include
environment=($(kubectl get ns --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | grep -v "default\|kube-system\|ingress-nginx\|kube-node-lease\|kube-public\|monitoring"))
#Specify mails
To="anilkuscu95@gmail.com"
From="alertmanager@gmail.com"

printf "\n"
echo "--------------------------$(tput setaf 2)CRONJOB'S STATUS$(tput sgr0)--------------------------------"
printf "\n"
for env in "${environment[@]}"
do
printf "\n"
echo "--------------------------environment: " $env "--------------------------------"
printf "\n"

jobs=($(kubectl get cj -n $env --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}'))

for job in "${jobs[@]}"
do

job_status=$(kubectl get po -n $env | grep $job | awk '{print $3}')
pod_name=$(kubectl get po -n $env | grep $job | awk '{print $1}')
case $job_status in
     Running )
          age=$(kubectl get po -n $env | grep $job | awk '{print $5}' | sed 's/.*s//g' | sed 's/m.*//g') 
          if [[ $age -ge 5 ]];then
          echo $job "$(tput setaf 1) Job Status Running but it is running overtime,mailing... $(tput sgr0)" $job_status
          printf "To:$To\nFrom:$From\nSubject: Some of jobs have problem.\n\n\n\n\nOn $env namespace,this job has a problem and it has restarted: $job status: $job_status \n $(kubectl get po -n $env | grep $job) \n $(kubectl describe po -n $env $pod_name)\n\n\n\n\n\n\n\LOGS\n\n\n $(kubectl logs -n $env $pod_name)" > jobs-mail.txt
          ssmtp $To < jobs-mail.txt
          #curl version
          #curl --url 'smtps://smtp.gmail.com:465' --ssl-reqd --mail-from $From --mail-rcpt $To --upload-file jobs-mail.txt --user '$From:<your-mail-pass>' --insecure            
          kubectl delete pod -n $env $pod_name        
          else
          echo $job "no problem" $job_status 
          fi
          ;;
    CrashLoopBackOff | Failed | Error | Unknown | ErrImagePull)
          echo $job "$(tput setaf 1) there is a problem with pod status  $(tput sgr0)"  $job_status
          printf "To:$To\nFrom:$From\nSubject: Some of jobs have problem.\n\n\n\n\nOn $env namespace,this job has a problem: $job status: $job_status \n $(kubectl get po -n $env | grep $job) \n $(kubectl describe po -n $env $pod_name)\n\n\n\n\n\n\n\LOGS\n\n\n $(kubectl logs -n $env $pod_name)" > jobs-mail.txt
          ssmtp $To < jobs-mail.txt
          #curl version
          #curl --url 'smtps://smtp.gmail.com:465' --ssl-reqd --mail-from $From --mail-rcpt $To --upload-file jobs-mail.txt --user '$From:<your-mail-pass>' --insecure            
          ;;
    Waiting | Pending | Init:0/3 | Init:1/3 | Init:2/3 | Init:3/3 | PodInitializing | Completed | ContainerCreating )
          age=$(kubectl get po -n $env | grep $job | awk '{print $5}' | sed 's/.*s//g' | sed 's/m.*//g')
          if [[ $age -ge 2 ]];then
          echo "$(tput setaf 1) The pod state has a problem  $(tput sgr0) " $job "status:" $job_status
          printf "To:$To\nFrom:$From\nSubject: Some of jobs have problem.\n\n\n\n\nOn $env namespace,this job has a problem: $job status: $job_status \n $(kubectl get po -n $env | grep $job) \n $(kubectl describe po -n $env $pod_name)\n\n\n\n\n\n\n\LOGS\n\n\n $(kubectl logs -n $env $pod_name)" > jobs-mail.txt
          ssmtp $To < jobs-mail.txt
          #curl version
          #curl --url 'smtps://smtp.gmail.com:465' --ssl-reqd --mail-from $From --mail-rcpt $To --upload-file jobs-mail.txt --user '$From:<your-mail-pass>' --insecure            
          fi
          echo $job "no problem" $job_status
          ;;
    "")
          echo $job "not active yet"  $job_status
          ;;

    *)
          echo $job "$(tput setaf 1) there is some other problem  $(tput sgr0)"  $job_status
          printf "To:$To\nFrom:$From\nSubject: Some of jobs have problem.\n\n\n\n\nOn $env namespace,this job has a problem: $job status: $job_status \n $(kubectl get po -n $env | grep $job) \n $(kubectl describe po -n $env $pod_name)\n\n\n\n\n\n\n\LOGS\n\n\n $(kubectl logs -n $env $pod_name)" > jobs-mail.txt
          ssmtp $To < jobs-mail.txt
          #curl version
          #curl --url 'smtps://smtp.gmail.com:465' --ssl-reqd --mail-from $From --mail-rcpt $To --upload-file jobs-mail.txt --user '$From:<your-mail-pass>' --insecure            
          ;;
esac
done
done
## Deployments
echo "--------------------------$(tput setaf 2)DEPLOYMENT'S STATUS$(tput sgr0)--------------------------------"
environment=($(kubectl get ns --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | grep -v "default\|kube-system\|ingress-nginx\|kube-node-lease\|kube-public\|monitoring"))
for env in "${environment[@]}"
do
printf "\n"
echo "--------------------------environment: " $env "--------------------------------"
printf "\n"

deployments=($(kubectl get deploy -n $env --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}'))

for deployment in "${deployments[@]}"
do

restart_count=$(kubectl get po -n $env | grep $deployment | awk '{print $4}')
pod_name=$(kubectl get po -n $env | grep $deployment | awk '{print $1}')

if [[ restart_count -ge 1 ]]; then
          echo "$(tput setaf 1) this job has restarted, mailing ...  $(tput sgr0)" $deployment
          printf "To:$To\nFrom:$From\nSubject: Some of deployments are restarted.\n\n\n\n\nOn $env namespace,this deployment is restarted: $deployment restart_count: $restart_count \n\n $(kubectl describe po -n $env $pod_name)\n\n\n\n\n\n\n\LOGS\n\n\n $(kubectl logs -n $env $pod_name)" > jobs-mail.txt
          ssmtp $To < jobs-mail.txt
          #curl version
          #curl --url 'smtps://smtp.gmail.com:465' --ssl-reqd --mail-from $From --mail-rcpt $To --upload-file jobs-mail.txt --user '$From:<your-mail-pass>' --insecure            
          kubectl delete pod -n $env $pod_name
else
          echo $deployment "no problem" $restart_count
fi

done
done
