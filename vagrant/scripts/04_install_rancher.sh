#!/usr/bin/env bash

echo "-----------------------------------------------------------------"
echo -e "${INFO}`date +%F' '%T`: Install rancher"
echo "-----------------------------------------------------------------"

echo "**** 拉取镜像 ****"
docker pull rancher/rancher:v${RANCHER_VERSION}

echo "**** 启动 rancher ****"
docker run -d --restart=unless-stopped -p 8088:80 -p 8443:443 --privileged rancher/rancher:v${RANCHER_VERSION}

