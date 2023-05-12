#!/bin/bash
set -euo pipefail

COMMAND="broot"
SOURCE="https://dystroy.org/broot/download/x86_64-linux/broot"
DESTINATION="/usr/local/bin/${COMMAND}"

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

echo "Installing ${COMMAND}"
echo "  Source: ${SOURCE}"
echo "  Destination: ${DESTINATION}"

sudo curl "${SOURCE}" \
  --output "${DESTINATION}" \
  --progress-bar
sudo chmod +x "${DESTINATION}"

echo "Complete. Confirm with:"
echo "  ${COMMAND} --version"
