#!/bin/bash
set -euo pipefail

COMMAND="micro"
SOURCE="https://github.com/zyedidia/micro/releases/download/v2.0.11/micro-2.0.11-amd64.deb"

if [[ $(/usr/bin/id -u) -ne 0 ]]
then
  echo "❗  Failed to install. Root is required." >&2
  exit 1
fi

set +e
WHICH=$(which "${COMMAND}")
set -e

if [[ "${WHICH}" != "" ]]
then
  echo "❗  Failed to install. ${COMMAND} is already installed:" >&2
  echo "${WHICH}"
  exit 1
fi

TEMP_FILE=$(mktemp --dry-run)

echo "Installing ${COMMAND}"
echo "  Source: ${SOURCE}"
#echo "  Destination: ${DESTINATION}"

curl "${SOURCE}" \
  --location \
  --output "${TEMP_FILE}" \
  --progress-bar
 
dpkg -i "${TEMP_FILE}"

echo "Complete. Confirm with:"
echo "  ${COMMAND} --version"
