#!/bin/bash
set -uo pipefail

COMMAND="ncdu"
SOURCE="https://dev.yorhel.nl/download/ncdu-2.2.1-linux-x86_64.tar.gz"
DESTINATION="/usr/local/bin"

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

validate-not-installed() {
  WHICH=$(which "${COMMAND}")  
  if [[ "${WHICH}" != "" ]]
  then
    echo-warning "${COMMAND} is already installed:"
    echo-subsidiary "Path: ${WHICH}"
    exit 2
  fi
}

validate-is-root
validate-not-installed

echo-information "Installing ${COMMAND}"
echo-subsidiary "Source: ${SOURCE}"
echo-subsidiary "Destination: ${DESTINATION}"

echo-step "Downloading and installing"
if ! curl "${SOURCE}" \
       --show-error \
       --silent \
       | tar \
           --extract \
           --gzip \
           --directory "${DESTINATION}" \
           --file - "${COMMAND}"
then
  echo-error "Failed to download package"
  exit 1
fi

if ! chmod +x "${DESTINATION}"
then
  echo-error "Failed to grant execution permission"
  exit 1
fi

echo-success "Installed ${COMMAND}"
echo-subsidiary "$(${COMMAND} --version)"
