#!/bin/bash
set -uo pipefail

COMMAND="micro"
SOURCE="https://github.com/zyedidia/micro/releases/download/v2.0.11/micro-2.0.11-amd64.deb"

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

echo-step "Downloading package"
TEMP_FILE=$(mktemp --dry-run)
if ! curl "${SOURCE}" \
       --location \
       --output "${TEMP_FILE}" \
       --show-error \
       --silent
then
  echo-error "Failed to download package"
  exit 1
fi

echo-step "Installing package"
if ! dpkg -i "${TEMP_FILE}" > /dev/null
then
  echo-error "Failed to install package"
  exit 1
fi

echo-success "Installed ${COMMAND}"
echo-subsidiary "$(${COMMAND} --version)"
