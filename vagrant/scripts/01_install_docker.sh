#!/usr/bin/env bash

echo "-----------------------------------------------------------------"
echo -e "${INFO}`date +%F' '%T`: Install docker"
echo "-----------------------------------------------------------------"

if [[ -z "$DOCKER_CE_REPO_URL" ]]; then
  # 设置 Docker 官方的 Docker CE 仓库源
  DOCKER_CE_REPO_URL=https://download.docker.com/linux/centos/docker-ce.repo
fi
echo "Docker ce repo url: $DOCKER_CE_REPO_URL"

echo "****** Add docker repo ******"
yum-config-manager --add-repo $DOCKER_CE_REPO_URL

echo "****** Install docker ce ******"
yum install -y docker-ce-$DOCKER_VERSION

if [[ -n "$DOCKER_MIRROR_URL" ]]; then
  echo "****** Setting docker mirror ******"
  mkdir -p /etc/docker
  echo "{\"registry-mirrors\": [\"$DOCKER_MIRROR_URL\"]}" >> /etc/docker/daemon.json
fi

echo "****** Start docker ******"
# systemctl daemon-reload
systemctl enable docker
systemctl start docker
