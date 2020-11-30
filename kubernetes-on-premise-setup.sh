#!/bin/bash

#It is tested on debian 9 and it creates 1 node master cluster and you are be able to create pods on master node.

#You should disable swap via deleting swap lines on /etc/fstab file before operations.Also I recommend make your ip static.
	swapoff -a

    IP=$1
    if [[ $IP == "" ]];then
    IP=$(ip -4 addr | grep -v 127.0.0.1  |grep -oP '(?<=inet\s)\d+(\.\d+){3}')
    fi

    POD_NETWORK=$2
    if [[ $POD_NETWORK == "" ]];then
    POD_NETWORK="10.244.0.0/16"
    fi

#install docker first
	apt-get install apt-transport-https ca-certificates curl gnupg2 software-properties-common -y
	curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian stretch stable"
	apt-get update
	apt-get install docker-ce -y
#install kubectl,kubelet,kubeadm
	curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" >> /etc/apt/sources.list.d/kubernetes.list
	apt-get update
	apt-get install -y kubelet kubeadm kubectl
	apt-mark hold kubelet kubeadm kubectl
#initiate cluster
	kubeadm init --apiserver-advertise-address=$IP --pod-network-cidr=$POD_NETWORK 
	mkdir -p $HOME/.kube
	sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
	sudo chown $(id -u):$(id -g) $HOME/.kube/config
  kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
#for be able to schedule pod on master node
  kubectl taint nodes --all node-role.kubernetes.io/master-
