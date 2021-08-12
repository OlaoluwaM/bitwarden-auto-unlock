#!/usr/bin/env bash

rootDir=$(dirname $(dirname $0))
envFilePath="$rootDir/.env"

set -o allexport
. $envFilePath
set +o allexport

if [[ -z "$MASTER_PASSWORD" ]]; then
  read -t 20 -sp 'Bitwarden master password not set in .env, please provide it: ' MASTER_PASSWORD
  [[ -z "$MASTER_PASSWORD" ]] && echo "Script cannot run without bitwarden master password" && exit 1
fi

expect <(
  cat <<EOF
  spawn bw unlock
  expect "Master Password:"
  send "$MASTER_PASSWORD\r"
  interact
EOF
) 2>/dev/null 1>"$rootDir/tmp.txt"

sessionKey=$(grep -o '".*"' "$rootDir/tmp.txt" | sed 's/"//g' | uniq)
echo $sessionKey
rm "$rootDir/tmp.txt"
export BW_SESSION=$sessionKey
