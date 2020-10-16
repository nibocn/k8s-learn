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
sed -i '/swap/s/^/# /' /etc/fstab

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

echo "**** Host 配置 ****"
grep -xqF "${NODE1_IP} ${K8S_APISERVER_NAME}" /etc/hosts || echo "${NODE1_IP} ${K8S_APISERVER_NAME}" >> /etc/hosts

echo "**** 配置 kubectl 命令自动补全 ****"
grep -xqF "source <(kubectl completion zsh)" /root/.zshrc || echo "source <(kubectl completion zsh)" >> /root/.zshrc
grep -xqF "source <(kubectl completion zsh)" /home/vagrant/.zshrc || echo "source <(kubectl completion zsh)" >> /home/vagrant/.zshrc

if [[ `hostname` == ${NODE1_HOSTNAME} ]]; then
  echo "**** 配置 kubeadm ****"
cat > /opt/k8s/kubeadm-config.yaml <<EOF
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: v${K8S_VERSION}
imageRepository: registry.aliyuncs.com/k8sxio
controlPlaneEndpoint: "${K8S_APISERVER_NAME}:6443"
apiServer:
  extraArgs:
    advertise-address: ${NODE1_IP}
networking:
  serviceSubnet: "10.96.0.0/16"
  podSubnet: "${K8S_POD_SUBNET}"
  dnsDomain: "cluster.local"
EOF

  echo "**** 指定 master 节点 k8s 使用的 IP ****"
  echo "KUBELET_EXTRA_ARGS=\"--node-ip=${NODE1_IP}\"" | tee /etc/sysconfig/kubelet

  systemctl restart kubelet

  if [[ ! -f "/root/.kube/config" ]]; then
    echo "**** Kubeadm init ****"
    kubeadm init --config=/opt/k8s/kubeadm-config.yaml --upload-certs
    mkdir -p /root/.kube
    cp -i /etc/kubernetes/admin.conf /root/.kube/config
    echo "**** 安装 calico 网络插件 ****"
    curl https://kuboard.cn/install-script/calico/calico-3.13.1.yaml -o /opt/k8s/calico-3.13.1.yaml
    # kubectl apply -f /opt/k8s/calico-3.13.1.yaml
  fi

else

  # echo "**** 拉取工作节点相关镜像 ****"
  if [[ `hostname` == ${NODE2_HOSTNAME} ]]; then
    echo "**** 指定 node2 节点 k8s 使用的 IP ****"
    echo "KUBELET_EXTRA_ARGS=\"--node-ip=${NODE2_IP}\"" | tee /etc/sysconfig/kubelet
  elif [[ `hostname` == ${NODE3_HOSTNAME} ]]; then
    echo "**** 指定 node3 节点 k8s 使用的 IP ****"
    echo "KUBELET_EXTRA_ARGS=\"--node-ip=${NODE3_IP}\"" | tee /etc/sysconfig/kubelet
  fi

  systemctl restart kubelet
fi
