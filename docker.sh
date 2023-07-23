#!/bin/bash
set -uo pipefail

COMMAND="docker"
DOCKER_USER="${1:-}"

# Install docker
# Source: https://docs.docker.com/engine/install/ubuntu/

echo-success () {
  echo -e "\e[32m ✔  $1\e[0m" >&2
}

echo-information () {
  echo -e "\e[34m ⓘ  $1\e[0m" >&2
}

echo-error () {
  echo -e "\e[31m !  $1\e[0m" >&2
}

echo-warning () {
  echo -e "\e[33m ⚠  $1\e[0m" >&2
}

echo-subsidiary () {
  echo -e "\e[37m    $1\e[0m" >&2
}

echo-step () {
  echo -e "\e[0m »  $1\e[0m" >&2
}

validate-is-root() {
  if [[ $(/usr/bin/id -u) -ne 0 ]]
  then
    echo-error "Root is required"
    exit 1
  fi
}

validate-is-root

echo-information "Installing ${COMMAND}"

echo-step "Uninstall old versions"
for PACKAGE in docker docker-engine docker.io containerd runc
do
  apt-get remove "${PACKAGE}" --quiet --yes
done

echo-step "Installing apt dependencies"
if ! (
  set -e
  apt-get update --quiet > /dev/null
  apt-get install --quiet --yes \
    ca-certificates \
    curl \
    gnupg
)
then
  echo-error "Failed to install apt dependencies"
  exit 1
fi

echo-step "Setup the Docker repository"
if ! (
  set -e
  mkdir -m 0755 -p /etc/apt/keyrings
  curl --fail --silent --show-error --location \
    https://download.docker.com/linux/ubuntu/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null
)
then
  echo-error "Failed to setup the Docker repository"
  exit 1
fi

echo-step "Install Docker Engine"
if ! (
  set -e
  apt-get update --quiet > /dev/null
  apt-get install --quiet --yes \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin
)
then
  echo-error "Failed to setup the Docker repository"
  exit 1
fi

# Post install steps
# Source: https://docs.docker.com/engine/install/linux-postinstall/

if [[ "${DOCKER_USER}" == "" ]]
then
  echo-warning "No docker user provided"
  echo-subsidiary "Skipping post install steps"
  exit 0
fi

echo-step "Create the docker group"
if ! groupadd docker
then
  echo-warning "Failed to create the docker group"
fi

echo-step "Add user ${DOCKER_USER} to the docker group"
if ! usermod --append --groups docker "${DOCKER_USER}"
then
  echo-warning "Failed to add user the docker group"
fi

echo-step "Reload groups"
newgrp docker
if ! newgrp docker
then
  echo-warning "Failed to reload group"
fi

# TODO: Change docker logging provider
# Source: https://docs.docker.com/engine/install/linux-postinstall/#configure-default-logging-driver
