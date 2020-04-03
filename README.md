# kubernetes-bash-scripts

# pod-checker
This script check pods and jobs with cron.You should add this script to crontab(generally /etc/crontab) for scheduled running.It runs for every namespaces that you specify and If there are any restarts(or job's running took longer than necessary time) on workload it sends mail.
ssmtp should be installed on system or you can use curl version for mailing.
