only master node execute:
---
    kubeadm init --apiserver-advertise-address=10.0.0.18   --image-repository registry.aliyuncs.com/google_containers  --pod-network-cidr=192.168.0.0/16
    <!-- --apiserver-advertise-address指定apiServer的地址 -->
    <!-- --image-repository指定镜像下载的仓库，因为某些原因，国内这里指定的是阿里云的镜像仓库 -->
    <!-- --pod-network-cidr指定pod的CIDR用于限制pod的ip范围，我们后面是有flannel网络，所以就直接配置192.168网段 -->
    <!-- kubeadm reset ,清除cluster -->

    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

