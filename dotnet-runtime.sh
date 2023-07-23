#!/bin/bash

# Install .NET Runtime
# Source: https://learn.microsoft.com/en-us/dotnet/core/install/linux-ubuntu

COMMAND="dotnet"
PACKAGE="dotnet-runtime-7.0"

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

echo-information "Installing ${PACKAGE}"

echo-step "Add the Microsoft package repository"
if ! (
  set -e
  declare repo_version=$(if command -v lsb_release &> /dev/null; then lsb_release -r -s; else grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"'; fi)

  # Download Microsoft signing key and repository
  curl "https://packages.microsoft.com/config/ubuntu/${repo_version}/packages-microsoft-prod.deb" \
    --location \
    --output "${TEMP_FILE}" \
    --show-error \
    --silent

  # Install Microsoft signing key and repository
  dpkg -i "${TEMP_FILE}" > /dev/null
  
  # Clean up
  rm "${TEMP_FILE}"
  )
then
  echo-error "Failed to add the Microsoft package repository"
  exit 1
fi

echo-step "Install .NET Runtime"
if ! (
  set -e
  apt-get update --quiet > /dev/null
  apt-get install ${PACKAGE} --yes --quiet
  )
then
  echo-error "Failed to install .NET Runtime"
  exit 1
fi

VERSION=$(${COMMAND} --version)
echo-success "Installed ${PACKAGE}"
echo-subsidiary "${VERSION}"
