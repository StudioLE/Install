#!/bin/bash
set -euo pipefail

COMMAND="ncdu"
SOURCE="https://dev.yorhel.nl/download/ncdu-2.2.1-linux-x86_64.tar.gz"
DESTINATION="/usr/local/bin"

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

curl "${SOURCE}" \
  --progress-bar \
   | tar \
   --extract \
   --gzip \
   --directory "${DESTINATION}" \
   --file - "${COMMAND}"
chmod +x "${DESTINATION}/${COMMAND}"

echo "Complete. Confirm with:"
echo "  ${COMMAND} --version"
