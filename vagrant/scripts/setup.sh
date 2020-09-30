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

# Install Docker
sh /vagrant/scripts/01_install_docker.sh
