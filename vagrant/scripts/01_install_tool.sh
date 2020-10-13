#!/usr/bin/env bash

echo "-----------------------------------------------------------------"
echo -e "${INFO}`date +%F' '%T`: Install tool"
echo "-----------------------------------------------------------------"

echo "**** Install vim zsh unzip ****"
yum install -y vim zsh unzip

mv /etc/vimrc{,.bak}
cp /vagrant/config/vimrc /etc/

# Config oh-my-zsh
cp /vagrant/software/ohmyzsh-master.zip /opt
rm -rf /opt/ohmyzsh-master
rm -rf /opt/oh-my-zsh
unzip /opt/ohmyzsh-master.zip -d /opt
mv /opt/{ohmyzsh-master,oh-my-zsh}
sed -i 's/export ZSH=$HOME\/.oh-my-zsh/export ZSH=\/opt\/oh-my-zsh/g' /opt/oh-my-zsh/templates/zshrc.zsh-template
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="ys"/g' /opt/oh-my-zsh/templates/zshrc.zsh-template
sed -i 's/plugins=(git)/plugins=(git docker)/g' /opt/oh-my-zsh/templates/zshrc.zsh-template
sed -i 's/# DISABLE_AUTO_UPDATE="true"/DISABLE_AUTO_UPDATE="true"/g' /opt/oh-my-zsh/templates/zshrc.zsh-template
cp /opt/oh-my-zsh/templates/zshrc.zsh-template /home/vagrant/.zshrc
cp /opt/oh-my-zsh/templates/zshrc.zsh-template /root/.zshrc
chsh -s $(which zsh) vagrant
chsh -s $(which zsh) root
