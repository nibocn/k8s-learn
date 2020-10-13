#!/usr/bin/env bash

echo "-----------------------------------------------------------------"
echo -e "${INFO}`date +%F' '%T`: Install kubernetes"
echo "-----------------------------------------------------------------"

mkdir -p /opt/k8s

echo "**** Disable SELINUX ****"
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

echo "**** Disable swap ****"
swapoff -a
yes | cp /etc/fstab{,.bak}
cat /etc/fstab.bak | grep -v swap | tee /etc/fstab

echo "**** Config network ****"
cat > /etc/sysctl.d/k8s.conf <<EOF
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
net.ipv6.conf.all.forwarding = 1
EOF

modprobe br_netfilter
sysctl -p /etc/sysctl.d/k8s.conf

echo "**** 安装 kubeadm、kubelet、kubectl ****"
cat > /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

yum install -y kubelet-${K8S_VERSION} kubectl-${K8S_VERSION} kubeadm-${K8S_VERSION}

echo "**** 启动 kubelet ****"
systemctl daemon-reload
systemctl enable kubelet
systemctl start kubelet

if [[ `hostname` == ${NODE1_HOSTNAME} ]]; then
  echo "**** Host 配置 ****"
  cat /etc/hosts | grep -v ${K8S_APISERVER_NAME} | tee /etc/hosts
  echo "${NODE1_IP}     ${K8S_APISERVER_NAME}" | tee -a /etc/hosts
  echo "**** 配置 kubeadm ****"
cat > /opt/k8s/kubeadm-config.yaml <<EOF
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: v${K8S_VERSION}
imageRepository: registry.aliyuncs.com/k8sxio
controlPlaneEndpoint: "${K8S_APISERVER_NAME}:6443"
networking:
  serviceSubnet: "10.96.0.0/16"
  podSubnet: "${K8S_POD_SUBNET}"
  dnsDomain: "cluster.local"
EOF
  # docker pull cnych/kube-apiserver-amd64:v1.10.0
  # docker pull cnych/kube-scheduler-amd64:v1.10.0
  # docker pull cnych/kube-controller-manager-amd64:v1.10.0
  # docker pull cnych/kube-proxy-amd64:v1.10.0
  # docker pull cnych/k8s-dns-kube-dns-amd64:1.14.8
  # docker pull cnych/k8s-dns-dnsmasq-nanny-amd64:1.14.8
  # docker pull cnych/k8s-dns-sidecar-amd64:1.14.8
  # docker pull cnych/etcd-amd64:3.1.12
  # docker pull cnych/flannel:v0.10.0-amd64
  # docker pull cnych/pause-amd64:3.1

  # docker tag cnych/kube-apiserver-amd64:v1.10.0 k8s.gcr.io/kube-apiserver-amd64:v1.10.0
  # docker tag cnych/kube-scheduler-amd64:v1.10.0 k8s.gcr.io/kube-scheduler-amd64:v1.10.0
  # docker tag cnych/kube-controller-manager-amd64:v1.10.0 k8s.gcr.io/kube-controller-manager-amd64:v1.10.0
  # docker tag cnych/kube-proxy-amd64:v1.10.0 k8s.gcr.io/kube-proxy-amd64:v1.10.0
  # docker tag cnych/k8s-dns-kube-dns-amd64:1.14.8 k8s.gcr.io/k8s-dns-kube-dns-amd64:1.14.8
  # docker tag cnych/k8s-dns-dnsmasq-nanny-amd64:1.14.8 k8s.gcr.io/k8s-dns-dnsmasq-nanny-amd64:1.14.8
  # docker tag cnych/k8s-dns-sidecar-amd64:1.14.8 k8s.gcr.io/k8s-dns-sidecar-amd64:1.14.8
  # docker tag cnych/etcd-amd64:3.1.12 k8s.gcr.io/etcd-amd64:3.1.12
  # docker tag cnych/flannel:v0.10.0-amd64 quay.io/coreos/flannel:v0.10.0-amd64
  # docker tag cnych/pause-amd64:3.1 k8s.gcr.io/pause-amd64:3.1
else
  echo "**** 拉取工作节点相关镜像 ****"
  # docker pull cnych/kube-proxy-amd64:v1.10.0
  # docker pull cnych/flannel:v0.10.0-amd64
  # docker pull cnych/pause-amd64:3.1
  # docker pull cnych/kubernetes-dashboard-amd64:v1.8.3
  # docker pull cnych/heapster-influxdb-amd64:v1.3.3
  # docker pull cnych/heapster-grafana-amd64:v4.4.3
  # docker pull cnych/heapster-amd64:v1.4.2
  # docker pull cnych/k8s-dns-kube-dns-amd64:1.14.8
  # docker pull cnych/k8s-dns-dnsmasq-nanny-amd64:1.14.8
  # docker pull cnych/k8s-dns-sidecar-amd64:1.14.8

  # docker tag cnych/flannel:v0.10.0-amd64 quay.io/coreos/flannel:v0.10.0-amd64
  # docker tag cnych/pause-amd64:3.1 k8s.gcr.io/pause-amd64:3.1
  # docker tag cnych/kube-proxy-amd64:v1.10.0 k8s.gcr.io/kube-proxy-amd64:v1.10.0

  # docker tag cnych/k8s-dns-kube-dns-amd64:1.14.8 k8s.gcr.io/k8s-dns-kube-dns-amd64:1.14.8
  # docker tag cnych/k8s-dns-dnsmasq-nanny-amd64:1.14.8 k8s.gcr.io/k8s-dns-dnsmasq-nanny-amd64:1.14.8
  # docker tag cnych/k8s-dns-sidecar-amd64:1.14.8 k8s.gcr.io/k8s-dns-sidecar-amd64:1.14.8

  # docker tag cnych/kubernetes-dashboard-amd64:v1.8.3 k8s.gcr.io/kubernetes-dashboard-amd64:v1.8.3
  # docker tag cnych/heapster-influxdb-amd64:v1.3.3 k8s.gcr.io/heapster-influxdb-amd64:v1.3.3
  # docker tag cnych/heapster-grafana-amd64:v4.4.3 k8s.gcr.io/heapster-grafana-amd64:v4.4.3
  # docker tag cnych/heapster-amd64:v1.4.2 k8s.gcr.io/heapster-amd64:v1.4.2
fi

