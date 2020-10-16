echo "-----------------------------------------------------------------"
echo -e "${INFO}`date +%F' '%T`: Setup"
echo "-----------------------------------------------------------------"

echo "-----------------------------------------------------------------"
echo -e "${INFO}`date +%F' '%T`: 语言本地化配置"
echo "-----------------------------------------------------------------"
echo LANG=en_US.utf-8 >> /etc/environment
echo LC_ALL=en_US.utf-8 >> /etc/environment

echo "-----------------------------------------------------------------"
echo -e "${INFO}`date +%F' '%T`: 系统时区设置"
echo "-----------------------------------------------------------------"
sudo timedatectl set-timezone $SYSTEM_TIMEZONE

echo "-----------------------------------------------------------------"
echo -e "${INFO}`date +%F' '%T`: 启用密码登录"
echo "-----------------------------------------------------------------"
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd


# Install tool
sh /vagrant/scripts/01_install_tool.sh
# Install docker
sh /vagrant/scripts/02_install_docker.sh
if [[ `hostname` == ${NODE4_HOSTNAME} ]]; then
  # Install rancher
  sh /vargrant/scripts/04_install_rancher.sh
else
  # Install kubernetes
  sh /vagrant/scripts/03_install_kubernetes.sh
fi
