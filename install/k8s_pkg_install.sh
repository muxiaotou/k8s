#!/bin/bash
#for v1.20.4
#all node execute, include master

#添加hostname到/etc/hosts环回地址的行末
name=`hostname`
sed -i "/127\.0\.0\.1/s/$/ ${name}/" /etc/hosts

#禁用swap
swapoff -a ; sed -i "/ swap /s/^/#/" /etc/fstab

#禁用selinux
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=disabled/g' /etc/selinux/config

#加载br_netfilter module
modprobe br_netfilter

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

#安装docker CE
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

yum install -y containerd.io-1.2.13 docker-ce-19.03.11 docker-ce-cli-19.03.11

mkdir /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{
"exec-opts": ["native.cgroupdriver=systemd"],
"log-driver": "json-file",
"log-opts": {
"max-size": "100m"
},
"storage-driver": "overlay2",
"storage-opts": [
"overlay2.override_kernel_check=true"
]
}
EOF

mkdir -p /etc/systemd/system/docker.service.d
systemctl enable docker;systemctl daemon-reload;systemctl restart docker

#安装kubeadm、kubelet 和 kubectl
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
EOF

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

systemctl enable --now kubelet

echo "Please reboot instance "
