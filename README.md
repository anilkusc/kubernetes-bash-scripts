# KUBERNETES BASH SCRIPTS

# pod-checker
This script checks pods and jobs with cron.You should add this script to crontab(generally /etc/crontab) for scheduled running.It runs for every namespaces that you specify and If there are any restarts(or job's running took longer than necessary time) on workload it sends mail.
ssmtp should be installed on system and you can use curl version for mailing.
You should run this script on master.

# image-checker
This script checks if there is a new version of the image it restart pods to fetch new version of the image.You can cron this script or run it manually.
jq should be installed on system and ImagePullPolicy should set Always
You should run this script on master.

# pod-restarter
You can schedule restart some of pods in all namespaces with this script.For example if you have some pods that have to be restarted time to tim
You should run this script on master.

# volume-checker
You can check your hostpath volumes one by one and if the volume size bigger than wanted value it sends you e-mail.
ssmtp should be installed on system.
You should run this script on nodes.

# image-update
You can update images in bulk
You should run this script on nodes
